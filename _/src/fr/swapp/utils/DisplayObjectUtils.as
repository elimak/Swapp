package fr.swapp.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	
	/**
	 * Classe utilitaire de gestion des DisplayObjects.
	 * @author ZoulouX
	 */
	public class DisplayObjectUtils
	{
		/**
		 * Récupérer le numéro d'une image par le nom de son label.
		 * @param	pMovieClip : Le clip
		 * @param	pLabel : Le label de cette image
		 * @param	pStrict : Si oui, la casse devra être respectée
		 * @return : Le numéro de l'image
		 */
		public static function getFrameByLabel (pMovieClip:MovieClip, pLabel:String, pStrict:Boolean = false):uint
		{
			// Compter le nombre de labels
			var t:uint = pMovieClip.currentLabels.length;
			
			// Parcourir tous ces labels
			for (var i:uint = 0; i < t; i++)
			{
				// Récupérer le nom de ce label
				var n:String = FrameLabel(pMovieClip.currentLabels[i]).name;
				
				// Vérifier s'il correspond de près ou de loin
				if (pStrict && (n == pLabel) || !pStrict && (n.toLowerCase() == pLabel.toLowerCase()))
					return FrameLabel(pMovieClip.currentLabels[i]).frame;
			}
			
			// Sinon on retourne 0
			return 0;
		}
		
		/**
		 * Aller à une image et lire si elle existe
		 * @param	pMovieClip : Le clip
		 * @param	pLabel : Le nom de l'image
		 * @return : Retourne le booleen de la réussite
		 */
		public static function checkAndPlay (pMovieClip:MovieClip, pLabel:String):Boolean
		{
			// Récupérer le numéro de la fram
			var n:uint = getFrameByLabel(pMovieClip, pLabel);
			
			// Vérifier si l'image à été trouvée
			if (n > 0)
			{
				// On va à l'image
				pMovieClip.gotoAndPlay(n);
				
				// Et on retourne que c'est ok
				return true;
			}
			else return false;
		}
		
		/**
		 * Aller à une image est arrêter si elle existe
		 * @param	pMovieClip : Le clip
		 * @param	pLabel : Le nom de l'image
		 * @return : retourne le booleen de la réussite
		 */
		public static function checkAndStop (pMovieClip:MovieClip, pLabel:String):Boolean
		{
			// Récupérer le numéro de la fram
			var n:uint = pMovieClip.getFrameByLabel(pLabel);
			
			// Vérifier si l'image à été trouvée
			if (n > 0)
			{
				// On va à l'image
				pMovieClip.gotoAndStop(n);
				
				// Et on retourne que c'est ok
				return true;
			}
			else return false;
		}
		
		/**
		 * Passer au premier plan
		 * @param	pDisplayObject : Le displayObject
		 */
		public static function bringToFront (pDisplayObject:DisplayObject):void
		{
			// Si le DO à un parent
			if (pDisplayObject.parent != null)
				pDisplayObject.parent.setChildIndex(pDisplayObject, pDisplayObject.parent.numChildren - 1);
		}
		
		/**
		 * Passer en background
		 * @param	pDisplayObject : Le displayObject
		 */
		public static function bringToBack (pDisplayObject:DisplayObject):void
		{
			// Si le DO à un parent
			if (pDisplayObject.parent != null)
				pDisplayObject.parent.setChildIndex(pDisplayObject, 0);
		}
		
		/**
		 * Passer au plan au dessus
		 * @param	pDisplayObject : Le displayObject
		 */
		public static function bringUp (pDisplayObject:DisplayObject):void
		{
			// Si le DO à un parent
			if (pDisplayObject.parent != null)
				pDisplayObject.parent.setChildIndex(pDisplayObject, Math.min(pDisplayObject.parent.numChildren - 1, pDisplayObject.parent.getChildIndex(pDisplayObject) + 1));
		}
		
		/**
		 * Passer au plan en dessous
		 * @param	pDisplayObject : Le displayObject
		 */
		public static function bringDown (pDisplayObject:DisplayObject):void
		{
			// Si le DO à un parent
			if (pDisplayObject.parent != null)
				pDisplayObject.parent.setChildIndex(pDisplayObject, Math.max(0, pDisplayObject.parent.getChildIndex(pDisplayObject) - 1));
		}
		
		/**
		 * Récupérer la liste des parents d'un DisplayObject. Le premier parent en premier, jusqu'a stage.
		 * L'objet doit être ajouté sur la scène.
		 * @param	pObject : L'objet sur lequel on doit récupérer la liste des parents.
		 * @return La liste des parents de l'objet.
		 */
		public static function getParentsOf (pObject:DisplayObject):Vector.<DisplayObjectContainer>
		{
			// Vérifier qu'on soit bien sur un élément du stage
			if (pObject.stage == null)
			{
				throw new SwappUtilsError("DiplayObjectUtils.getParentsOf", "pObject.stage can't be null.");
				return;
			}
			
			// La liste des parents
			var parentsList:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>;
			
			// Le parent de notre élément
			var parent:DisplayObjectContainer = pObject.parent;
			
			// Tant qu'on n'est pas sur le stage
			while (parent != pObject.stage)
			{
				// On ajoute le parent à notre liste de parents
				parentsList.push(parent);
				
				// oO
				parent = parent.parent;
			}
			
			// On ajoute le stage à la fin
			parentsList.push(pObject.stage);
			
			// On retourne la liste
			return parentsList;
		}
		
		/**
		 * Récupérer le premier parent d'un type sépcifique (peut chercher via une interface)
		 * @param	pObject : L'objet de départ
		 * @param	pType : Le type du parent
		 * @return : Le DisplayObjectContainer parent de pObject, de type pType, le plus proche de pObject.
		 */
		public static function getParentOfType (pObject:DisplayObject, pType:Class):DisplayObjectContainer
		{
			// Cibler le parent
			var parent:DisplayObjectContainer = pObject.parent;
			
			// Tant qu'on est pas sur le bon type de parent
			while (!(parent is pType))
			{
				// oO
				parent = parent.parent;
				
				// Si on est tombé sur le stage
				if (parent == pObject.stage)
				{
					// Alors c'est qu'on a rien trouvé
					return null;
				}
			}
			
			// Retourner le parent qui a été trouvé
			return parent;
		}
		
		/**
		 * Remettre la matrice 3D d'un DisplayObject à 0.
		 * Les propriétés x et y seront replacées depuis la matrice 3D.
		 * @param	pDisplayObject : Le displayObject à remettre à 0
		 */
		public static function resetThreeDeeMatrix (pDisplayObject:DisplayObject):void
		{
			// Récupérer la position de notre objet depuis la matrice 3D
			const x:Number = pDisplayObject.x;
			const y:Number = pDisplayObject.y;
			
			// Détruire la transformation
			pDisplayObject.transform.matrix3D = null;
			
			// Réappliquer la position
			pDisplayObject.x = x;
			pDisplayObject.y = y;
		}
	}
}