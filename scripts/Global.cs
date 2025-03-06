using Godot;
using System;

public partial class Global : Node
{
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("debug_main_menu"))
		{
			GetTree().ChangeSceneToFile("res://scenes/menu/MainMenu.tscn");
		}
	}
}
