using Godot;
using System;

// [GlobalClass]
public partial class Player : CharacterBody3D
{
	// Exports
	[Export(PropertyHint.Range, "0.1,10,")]
	public float speed = 4.0f;
	[Export(PropertyHint.Range, "0.1,10,")]
	public float jumpVelocity = 6.0f;
	[Export(PropertyHint.Range, "0.1,10,")]
	public float speedRotation = 8.0f;
	[Export]
	public Vector3 DefaultCamPosition = new Vector3(0, 1.2f, 4.0f);
	// Nodes
	protected Camera3D camera = null;
	protected AnimationPlayer animationPlayer = null;
	protected Sprite3D sprite = null;

	// Porperties
	protected Vector3 PreviousDirection = Vector3.ModelLeft;
	protected Vector3 RotateDirection = Vector3.Zero;
	protected Vector3 PreviousVelocity = Vector3.Zero;
	// Constants
	protected float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").As<float>();
	protected Vector3 gravityDirection = ProjectSettings.GetSetting("physics/3d/default_gravity_vector").As<Vector3>();

	public override void _Ready()
	{
		camera = GetNode<Camera3D>("Camera3D");
		camera.Position = DefaultCamPosition;
		animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
		animationPlayer.Play("idle");
		sprite = GetNode<Sprite3D>("Sprite3D");
	}

	public override void _Process(double delta)
	{
		if (Math.Abs(sprite.Rotation.Y) > 0.01f)
		{
			sprite.Rotation = sprite.Rotation.Lerp(RotateDirection, speedRotation * (float)delta);
		}
		else
		{
			sprite.Position = RotateDirection;
		}
		CameraHandler(delta);
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector3 velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
		{
			velocity += gravityDirection * gravity * (float)delta;
		}

		// Handle Jump.
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
		{
			velocity.Y = jumpVelocity;
		}

		// Get the input direction and handle the movement/deceleration.
		Vector2 inputDir = Input.GetVector("move_left", "move_right", "move_back", "move_front");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * speed;
			velocity.Z = direction.Z * speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, speed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, speed);
		}

		// Animation Handler
		if (velocity != Velocity || velocity == Vector3.Zero) {
			Velocity = velocity;
			AnimationHandler();
		}

		// Move the player.
		MoveAndSlide();
	}

	protected void CameraHandler(double delta)
	{
		switch (animationPlayer.CurrentAnimation)
		{
			case "jump":
				camera.Position = camera.Position with { Y = (float)Mathf.Lerp(camera.Position.Y, DefaultCamPosition.Y + 2, delta) };
				break;
			case "fall":
				camera.Position = camera.Position with { Y = (float)Mathf.Lerp(camera.Position.Y, DefaultCamPosition.Y - 2, delta) };
				break;
			case "run_front":
				break;
			case "run_back":
				break;
			case "run_side":
				Vector3 temp = new Vector3((float)Mathf.Lerp(camera.Position.X, DefaultCamPosition.X, delta), (float)Mathf.Lerp(camera.Position.Y, DefaultCamPosition.Y, delta), 1.0f);
				break;
			default:
				camera.Position = camera.Position.Lerp(DefaultCamPosition, (float)delta);
				break;
		}
	}

	protected void AnimationHandler()
	{
		if (Velocity.Y > 0)
		{
			if (IsOnFloor())
			{
				animationPlayer.Play("jump");
			}
		}
		else if (Velocity.Y < 0)
		{
			if (animationPlayer.CurrentAnimation != "fall")
			{
				animationPlayer.Play("fall");
			}
		}
		else if (Velocity.Z > 0)
		{
			if (animationPlayer.CurrentAnimation != "run_front")
			{
				animationPlayer.Play("run_front");
			}
		}
		else if (Velocity.Z < 0)
		{
			if (animationPlayer.CurrentAnimation != "run_back")
			{
				animationPlayer.Play("run_back");
			}
		}
		else if (Velocity.X != 0)
		{
			if (animationPlayer.CurrentAnimation != "run_side")
			{
				animationPlayer.Play("run_back");
			}
		}
		else if (animationPlayer.CurrentAnimation != "idle")
		{
			animationPlayer.Play("idle");
		}
	}
}
