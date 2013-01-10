package fr.swapp.graphic.components.lists 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import fr.swapp.touch.emulator.TouchEmulator;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class FreeVirtualList extends AVirtualList
	{
		/**
		 * L'inertie (1 infinie, 0 aucune)
		 */
		protected var _inertia						:Number						= .93;
		
		/**
		 * Le frein
		 */
		protected var _breakForce					:Number						= .15;
		
		
		/**
		 * Le constructeur
		 * @param	pDelegate : Le delegate de cette liste qui va fournir les éléments et les informations sur le nombre d'éléments
		 * @param	pOrientation : L'orientation de la liste (voir statiques)
		 */
		public function FreeVirtualList (pDelegate:IVirtualListDelegate, pOrientation:String = "vertical")
		{
			// Relayer la construction
			super(pDelegate, pOrientation);
		}
		
		
		/**
		 * Initialisation du composant
		 */
		override protected function addedHandler (event:Event = null):void
		{
			// Relayer
			super.addedHandler(event);
			
			// Activer la boucle
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * La boucle pour les déplacements du contenu
		 */
		protected function enterFrameHandler (event:Event):void
		{
			//trace("-");
			
			// Le déplacement n'est pas vérouillé par un drag
			if (!_dragLocked)
			{
				// Appliquer la vélocité
				if (_velocity != 0)
				{
					currentScroll += _velocity;
				}
				
				// Si on a assez de vélocité
				if (_velocity <= -.5 || _velocity >= .5)
				{
					// Appliquer l'inertie
					_velocity *= _inertia;
				}
				
				// On annule le peu d'inertie qu'on a
				else if (_velocity != 0)
				{
					_velocity = 0;
				}
			}
		}
		
		/**
		 * Déplacement avec la molette
		 */
		override protected function mouseWheelHandler (event:MouseEvent):void
		{
			// Si la molette est autorisée
			if (_mouseWheelEnabled)
			{
				// On applique la vélocité
				_velocity -= event.delta * 4;
			}
		}
		
		/**
		 * Vérouillage du déplacement
		 */
		override public function touchDragLock (pTarget:DisplayObject):void
		{
			// Si la liste est en mouvement
			if (_velocity != 0)
			{
				// Pas de vélocité
				_velocity = 0;
				
				// La liste a bougé
				_moved = true;
			}
			else
			{
				// La liste n'a pas bougé
				_moved = false;
			}
			
			// Le drag est vérouille
			_dragLocked = true;
		}
		
		/**
		 * Dévérouillage du déplacement
		 */
		override public function touchDragUnlock (pTarget:DisplayObject):void
		{
			// Le drag est dévérouillé
			_dragLocked = false;
		}
		
		/**
		 * Déplacement
		 */
		override public function touchDragging (pTarget:DisplayObject, pDirection:String, pXDelta:Number, pYDelta:Number, pPoints:Vector.<Point>):Boolean
		{
			// Vérifier la direction du drag
			if (
					pDirection == _dragDirection
					||
					(pDirection == TouchEmulator.UNKNOW_DIRECTION && _dragAllowUnknownDirection)
					||
					_dragAllowOppositeDirection
				)
			{
				// La liste a bougé
				_moved = true;
				
				// Récupérer la vélocité du point
				if (_deltaTouchVar == "pXDelta")
				{
					_velocity = pXDelta;
				}
				else if (_deltaTouchVar == "pYDelta")
				{
					_velocity = pYDelta;
				}
				
				// Récupérer la limite
				var limit:Number = getContentLimit();
				
				// Si on a une limite
				if (limit >= 0 || limit < 0)
				{
					// Diviser la vélocité
					_velocity = _velocity / _velocityOutBreak;
					
					// On applique cette vélocité au scroll
					_container[_positionVar] += _velocity;
					
					// Actualiser
					updateList();
				}
				else
				{
					// On applique cette vélocité au scroll
					_container[_positionVar] += _velocity;
					
					// Actualiser
					updateList();
					
					// On interdit les drag en amont
					return true;
				}
			}
			
			// Autoriser les parents à déplacer
			return false;
		}
		
		/**
		 * La liste dépasse, replacer la liste
		 * @param	pImmediate : Replacement immediat
		 */
		override protected function replaceList (pImmediate:Boolean = false):void
		{
			// Récupérer la limite
			var limit:Number = getContentLimit();
			
			// Si on a une limite
			if (limit >= 0 || limit < 0)
			{
				// Si le drag n'est pas vérouillé
				if (!_dragLocked)
				{
					// On freine le scroll vers cette limite
					_container[_positionVar] -= limit * (pImmediate ? 1 : _breakForce);
				}
				
				// Diviser la vélocité
				_velocity = _velocity / _velocityOutBreak;
				
				// Si on est proche de la destination
				if (limit < .5  && limit > -.5 && _velocity < .5 && _velocity > -.5)
				{
					// On place à la destination
					_container[_positionVar] -= limit;
				}
				else
				{
					// Invalider la liste car il nous reste de la distance
					invalidateList();
				}
			}
		}
		
		/**
		 * Déstruction
		 */
		override protected function removedHandler (event:Event):void
		{
			// Désactiver les listeners
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			// Relayer
			super.removedHandler(event);
		}
	}
}