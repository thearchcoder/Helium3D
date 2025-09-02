using System;
using Godot;

public partial class TestNode : Node
{
	[Export]
	public string m_TestProperty = "test";
	
	public void TestMethod()
	{
		GD.Print("method called from gdscript");
	}
	
	public override void _Ready()
	{
		GD.Print("c# script working");
	}
}
