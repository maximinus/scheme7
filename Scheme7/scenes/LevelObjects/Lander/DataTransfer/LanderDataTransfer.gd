extends Control

# show yourself, # wait for keypress M, play first sound
# wait for keypress, play second sound and fill bar

# also we check for end conditions on this screen
signal lander_spotted
signal download_finished

const DOWNLOAD_TIME = 10.0
const BAR_LENGTH = 396.0

var stage = 0
var processing = false
var downloading = false
var time_taken = 0.0
var completed = false
var resetting = false

func _ready():
	pass

func stageOne():
	processing = false
	$HeaderSFX.play()

func stageTwo():
	downloading = true
	$DownloadSFX.play()

func reset():
	if completed == true:
		hide()
		return
	if resetting == true:
		# already doing this
		return
	# stop everything
	stage = 0
	time_taken = 0.0
	downloading = false
	processing = false
	$Bar.region_rect.end.x = 0
	resetting = true
	$DownloadSFX.stop()
	$HeaderSFX.stop()
	$Bar.hide()
	$BarBorder.hide()
	$Margin/VBox/InfoLbl.text = 'TRANSFER INTERRUPTED'
	$Timer.start()

func _process(delta):
	if downloading == true:
		time_taken += delta
		$Bar.region_rect.end.x = (BAR_LENGTH / DOWNLOAD_TIME) * time_taken
		return
	if processing == false:
		return
	if Input.is_action_just_pressed('download'):
		if stage == 0:
			stageOne()
		elif stage == 1:
			stageTwo()

func _on_HeaderSFX_finished():
	if resetting == true:
		return
	$Margin/VBox/InfoLbl.text = 'Access Granted: Start Download'
	$BarBorder.show()
	$Bar.show()
	stage = 1
	processing = true

func _on_DownloadSFX_finished():
	if resetting == true:
		return
	$Bar.hide()
	$BarBorder.hide()
	$Margin/VBox/InfoLbl.text = 'DOWNLOAD COMPLETE'
	processing = false
	downloading = false
	completed = true

func _on_Timer_timeout():
	hide()
	$Margin/VBox/InfoLbl.text = 'Ready To Download: Initiate Sequence'
	resetting = false
