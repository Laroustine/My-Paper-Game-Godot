using Godot;
using System;

public partial class MainMenu : Control
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GetNode<VBoxContainer>("VBox").GetChild<Button>(0).GrabFocus();
		GetNode<Button>("VBox/Test").Pressed += () => GetTree().ChangeSceneToFile("res://lvl/lvl_test.tscn");
		GetNode<Button>("VBox/Jump").Pressed += () => GetTree().ChangeSceneToFile("res://lvl/lvl_geometry.tscn");
		GetNode<Button>("VBox/Quit").Pressed += () => GetTree().Quit();
	}
}
