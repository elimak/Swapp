package fr.swapp.core.mvc.concrete 
{
	import flash.display.Sprite;
	import fr.swapp.core.bundle.IBundle;
	
	/**
	 * Une vue dont le displayObject est un Sprite.
	 * @author ZoulouX
	 */
	public class SpriteView extends View
	{
		/**
		 * Récupérer le displayObject en tant que sprite
		 */
		public function get sprite ():Sprite { return _displayObject as Sprite }
		
		/**
		 * Le Bundle auquel appartient ce controlleur
		 */
		override public function set bundle (value:IBundle):void
		{
			// Enregistrer le Bundle
			_bundle = value;
			
			// Une fois qu'on a le Bundle, on peut créer le sprite
			attachDefaultDisplayObject();
		}
		
		/**
		 * Le constructeur
		 */
		public function SpriteView ()
		{
			super();
		}
		
		/**
		 * Création du displayObject par défaut
		 */
		protected function attachDefaultDisplayObject ():void
		{
			createAndAttachDisplayObject(Sprite);
		}
	}
}