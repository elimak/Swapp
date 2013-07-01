package fr.swapp.graphic.atlas
{
	import flash.display.BitmapData;
	import fr.swapp.core.roles.IDisposable;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.ArrayUtils;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class SAtlas implements IDisposable
	{
		/**
		 * BitmapData containg all textures
		 */
		protected var _bitmapData			:BitmapData;
		
		/**
		 * XML describing textures positions, name and sizes.
		 */
		protected var _xml					:XML;
		
		/**
		 * AtlasItem list
		 */
		protected var _items				:Array						= [];
		
		/**
		 * Textures density
		 */
		protected var _density				:Number;
		
		/**
		 * When disposed
		 */
		protected var _onDisposed			:Signal						= new Signal();
		
		
		/**
		 * BitmapData containg all textures
		 */
		public function get bitmapData ():BitmapData { return _bitmapData; }
		
		/**
		 * XML describing textures positions, name and sizes.
		 */
		public function get xml ():XML { return _xml; }
		
		/**
		 * Textures density
		 */
		public function get density ():Number { return _density; }
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Constructor
		 * @param	pBitmapData : BitmapData containg all textures
		 * @param	pAtlasXML : XML describing textures positions, name and sizes.
		 * @param	pDensity : Textures density.
		 */
		public function SAtlas (pBitmapData:BitmapData, pAtlasXML:XML, pDensity:Number = 1)
		{
			// TODO: Rendre compatible avec les atlas générés par texturePacker (offsets, rotation)
			
			// Vérifier que les valeurs ne soient pas nulles
			if (pBitmapData == null || pAtlasXML == null)
			{
				// On lève une erreur
				throw new GraphicalError("SAtlas.construct", "BitmapData and AtlasXML can't be null.");
			}
			else
			{
				// Enregistrer les valeurs
				_xml = pAtlasXML;
				_bitmapData = pBitmapData;
				_density = pDensity;
				
				// Parser l'XML
				parseData();
			}
		}
		
		/**
		 * Parse XML Data
		 */
		protected function parseData ():void
		{
			// Cibler le noeud des textures
			var subTextures:XMLList = _xml..SubTexture as XMLList;
			
			// Parcourir les noeud des textures
			var item:SAtlasItem;
			for each (var node:XML in subTextures)
			{
				// Créer l'item
				item = new SAtlasItem(node, this);
				
				// L'ajouter au tableau des items par son nom
				_items[item.name] = item;
			}
		}
		
		/**
		 * Get an atlas texture from its name.
		 * @param	pName : Name of the texture to get
		 * @return : AtlasItem which describe texture position from atlas. Will be null if texture can't be found.
		 */
		public function getAtlasItem (pName:String):SAtlasItem
		{
			// Si on a ce nom dans les items
			if (pName in _items)
			{
				// Retourner l'item
				return _items[pName] as SAtlasItem;
			}
			
			// Sinon on retourne null
			return null;
		}
		
		/**
		 * Get an atlas sequence for animation.
		 * @param	pSequenceName : The base name of the sequence. If you have a sequence starting with "Animation001", juste enter "Animation", and this method will get you all atlases begining with "Animation".
		 * @return Atlases sequence from name.
		 */
		public function getAtlasSequence (pSequenceName:String):Vector.<SAtlasItem>
		{
			// Le tableau temporaire pour pouvoir faire du sortOn
			var tempOut:Array = [];
			
			// Parcourir les noms des atlasItem
			for (var i:String in _items)
			{
				// Si ce nom correspond à la sequence
				if (i.indexOf(pSequenceName) == 0)
				{
					// On l'ajoute à la liste
					tempOut.push(_items[i]);
				}
			}
			
			// Trier la liste par nom
			tempOut.sortOn("name");
			
			// Retourner la liste sous forme de vector d'atlasItem
			return Vector.<SAtlasItem>(tempOut);
		}
		
		/**
		 * Get all availables textures names
		 */
		public function getNames ():Array
		{
			return ArrayUtils.getKeys(_items);
		}
		
		/**
		 * Destruction
		 */
		public function dispose ():void
		{
			// Disposer le bitmapData
			_bitmapData.dispose();
			
			// Signaler la destruction
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
		}
	}
}