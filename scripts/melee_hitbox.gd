extends HitBox

# when parry successfully done, send a hit to yourself
func parry():
	if owner.has_method("take_hit"):
		owner.take_hit(self)
