package backend;

class Achievement
{
	public var name:String;
	public var id:String;
	public var description:String;
	public var unlocked:Bool = false;
	public var hidden:Bool = false;

	/**
	 * [New Achievement!]
	 * @param name The name of your achievement.
	 * @param description The description of your achievement.
	 * @param id The id of your achievement.
	 * @param hidden Is your acheivement hidden?
	 */
	public function new(name:String, description:String, id:String, ?hidden:Bool = false)
	{
		this.name = name;
		this.description = description;
		this.id = id;
		this.hidden = hidden;
	}
}

class AchievementHandler
{
	public static var achievements:Array<Achievement> = [
		// basic
		new Achievement("A New Journey", "Make your first microphone.", 'nw_jrn'),
		new Achievement("Funny Rapping", "Make 1,000 microphones.", "fn_rp"),
		new Achievement("TMM... Too many microphones...", "Make 100,000 microphones.", "tmm"),
		// clicking
		new Achievement("V.S. Carpal Tunnel", "Make 1,000 microphones from clicking.", "carp_tnl"),
		// printer achievements
		new Achievement("3D Printed", "Have 1 3D Printer.", "1_3dp"),
		new Achievement("Printer Raid", "Have 50 3D Printers\n\"Must be getting expensive...\"", "50_3dp") //
	];
}
