using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Npc : StaticBody3D
{
	// Exports
	[ExportGroup("Info")]
	[Export]
	public string CharacterName = "NPC";
	[Export(PropertyHint.MultilineText)]
	public string DialogText = "";
	[ExportGroup("Voice")]
	[Export(PropertyHint.Dir)]
	public string VoicePath = "";
	[Export]
	public float VoiceSpeed = 0.1f;
	[ExportGroup("Visual")]
	[Export]
	private Texture2D _sprite = ResourceLoader.Load<Texture2D>("res://assets/image/sprite/character/steps_empty.png");
	public Texture2D Sprite
	{
		get => _sprite;
		set
		{
			_sprite = value;
			GetNode<Sprite3D>("Sprite").Texture = _sprite;
		}
	}
	// Constants
	public Vector3 BASE_SIZE = new Vector3(48, 48, 1);
	// Variables
	protected Dictionary<char, AudioStreamWav> VoiceFiles = new Dictionary<char, AudioStreamWav>();
	protected bool CanTalk = false;
	// Nodes
	private AudioStreamPlayer VoiceSound = null;
	private Timer VoiceTimer = null;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Voice
		VoiceSound = GetNode<AudioStreamPlayer>("TextBox/Voice");
		VoiceTimer = GetNode<Timer>("TextBox/Timer");
		VoiceTimer.WaitTime = VoiceSpeed;
		VoiceTimer.Timeout += PlayVoice;
		LoadVoice();
		// Dialog
		GetNode<Label>("TextBox/Panel/Margin/Text").Text = "";
		GetNode<Area3D>("Interact").BodyEntered += EnterInteraction;
		GetNode<Area3D>("Interact").BodyExited += ExitInteraction;
		// Name
		GetNode<Label>("NameDisplay/Panel/Name").Text = CharacterName;
		// Sprite
		GetNode<AnimationPlayer>("AnimationPlayer").Play("idle");
		Sprite = _sprite;
		SpriteScaling();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (CanTalk && Input.IsActionJustPressed("talk"))
		{
			GetNode<Label>("TextBox/Panel/Margin/Text").Text = "";
			GetNode<Control>("TextBox").Show();
			VoiceTimer.Start();
		}
	}

	private void LoadVoice()
	{
		if (!DirAccess.DirExistsAbsolute(VoicePath))
		{
			GD.PushWarning($"{Name}: Voice path not found at: {VoicePath}");
			return;
		}
		foreach (var letter in "abcdefghijklmnopqrstuvwxyz")
		{
			var path = VoicePath + "/" + letter + ".wav";
			if (FileAccess.FileExists(path))
			{
				VoiceFiles[letter] = ResourceLoader.Load<AudioStreamWav>(path);
			}
			else
			{
				GD.PushWarning($"{Name}: Voice file not found for {letter} at: {path}");
				VoiceFiles[letter] = null;
			}
		}
	}

	public void EnterInteraction(Node3D body)
	{
		if (body.Name == "Player")
		{
			CanTalk = true;
			GetNode<Control>("NameDisplay").Show();
		}
	}

	public void ExitInteraction(Node3D body)
	{
		if (body.Name == "Player")
		{
			CanTalk = false;
			VoiceTimer.Stop();
			GetNode<Control>("NameDisplay").Hide();
			GetNode<Control>("TextBox").Hide();
		}
	}

	protected void PlayVoice()
	{
		Label label = GetNode<Label>("TextBox/Panel/Margin/Text");
		if (label.Text != DialogText)
		{
			char letter = DialogText[label.Text.Length];
			label.Text += letter;
			if (letter >= 'A' && letter <= 'Z') {
				letter = (char)(letter - 'A' + 'a');
			}
			if (VoiceFiles.ContainsKey(letter))
			{
				VoiceSound.Stream = VoiceFiles[letter];
				VoiceSound.Play();
			}
		}
		else
		{
			VoiceTimer.Stop();
		}
	}

	protected void SpriteScaling()
	{
		Sprite3D sprite = GetNode<Sprite3D>("Sprite");
		Vector3 size = Vector3.One;
		if (sprite.Texture != null)
		{
			size.X = sprite.Texture.GetSize().X / sprite.Hframes;
			size.Y = sprite.Texture.GetSize().Y / sprite.Vframes;
		}
		sprite.Scale = BASE_SIZE / size;
	}
}
