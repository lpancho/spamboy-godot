extends Node2D

signal feed
signal full

var scoreScene = preload("res://scenes/scoreText.tscn")

export(int) var mail_capacity = 5
export (int) var mail_count = 0
var rate_limit_text = 0

func _ready():
	$debug.hide()

func feed(sender):
	if mail_count < mail_capacity:
		$stuffSound2.play()
		mail_count += 1
		$AnimationPlayer.play("feeded")
		spawn_score_text("+ 1")
		emit_signal("feed")
	else:
		$stuffSoundClose.play()
		$AnimationPlayer.play("full")
		$stuffSoundBad.play()
		spawn_score_text("FULL", "spawn_a", rate_limit_text, Color(0.8,0.8,0.8))
		rate_limit_text = 1
		get_parent().emit_signal("open_door")
		emit_signal("full")

func spawn_score_text(text, animation = "spawn_a", limit = 0, color = Color(1,1,1)):
	
	if limit > 0 and $spawnedText.get_child_count() >= limit:
		return
		
	var score = scoreScene.instance()
	score.text = text
	score.position = $scoreSpawn.position
	score.animation = animation
	score.text_color = color
	$spawnedText.add_child(score)

func _on_Area2D_body_entered(body):
	body.connect("stuff_mail",self,"feed") 

func _on_Area2D_body_exited(body):
	body.disconnect("stuff_mail",self,"feed") 
