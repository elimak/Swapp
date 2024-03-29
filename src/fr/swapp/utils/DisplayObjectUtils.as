﻿package fr.swapp.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.media.Video;
	
	/**
	 * Classe utilitaire de gestion des DisplayObjects.
	 * @author ZoulouX
	 */
	public class DisplayObjectUtils
	{
		/**
		 * ----------------------------------------------
		 * 					 ANIMATIONS
		 * ----------------------------------------------
		 */
		
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
				{
					return FrameLabel(pMovieClip.currentLabels[i]).frame;
				}
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
		 * ----------------------------------------------
		 * 					 STACK ORDER
		 * ----------------------------------------------
		 */
		
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
		 * Passer à un plan en particulier
		 */
		public static function bringTo (pDisplayObject:DisplayObject, pAt:int):void
		{
			// Si le DO à un parent
			if (pDisplayObject.parent != null)
				pDisplayObject.parent.setChildIndex(pDisplayObject, Math.max(0, Math.min(pAt, pDisplayObject.parent.numChildren)));
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 					 HIERARCHY
		 * ----------------------------------------------
		 */
		
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
				return null;
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
		 * Get child displayObject from complex path.
		 * @param	pContainer : The DisplayObjectContainer to search a child in
		 * @param	pPath : The path dot syntaxed like "firstLevel.myMovieClip.sprite"
		 * @return The targetted child by the path from pContainer.
		 */
		public static function getChildWithPath (pContainer:DisplayObjectContainer, pPath:String, pStrict:Boolean = true):DisplayObject
		{
			// Séparer le chemin sur les points
			var splittedPath:Array = pPath.split(".");
			
			// Le scope actuel
			var currentScope:DisplayObjectContainer = pContainer;
			var child:DisplayObject;
			
			// Parcourir chaque partie du chemin
			for each (var pathPart:String in splittedPath)
			{
				// Si cette partie du chemin existe dans le scope actuel
				if (pathPart in currentScope && currentScope[pathPart] is DisplayObject)
				{
					// On avance d'un niveau
					currentScope = currentScope[pathPart];
				}
				else
				{
					// Essayer de cibler l'enfant par son nom
					child = currentScope.getChildByName(pathPart);
					
					// S'il n'est pas null
					if (child != null && child is DisplayObjectContainer)
					{
						// On le cible
						currentScope = child as DisplayObjectContainer;
					}
					else
					{
						// Pas trouvé
						return null;
					}
				}
			}
			
			// Retourner le scope courrant
			return currentScope as DisplayObject;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 						 3D
		 * ----------------------------------------------
		 */
		
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
		
		/**
		 * Définir rapidement une projection 3D sur un objet.
		 * @param	pTarget : L'objet en question
		 * @param	pX : La position X du point de fuite
		 * @param	pY : La position Y du point de fuite
		 * @param	pFieldOfView : L'angle de vision (entre 0 et 180 non compris)
		 */
		public static function quickProjection (pTarget:DisplayObject, pX:Number = 0, pY:Number = 0, pFieldOfView:Number = 70):void
		{
			// Créer l'objet de configuration de la projection
			var perspectiveProjection:PerspectiveProjection = new PerspectiveProjection();
			
			// Définir le point de fuite et l'angle de vision
			perspectiveProjection.projectionCenter = new Point(pX, pY);
			perspectiveProjection.fieldOfView = pFieldOfView;
			
			// Appliquer cette configuration sur l'objet
			pTarget.transform.perspectiveProjection = perspectiveProjection;
		}
		
		
		
		/**
		 * ----------------------------------------------
		 * 						TIME
		 * ----------------------------------------------
		 */
		
		/**
		 * Wait for a specified frame numbers. Usefull to wait for graphics upload in GPU renderMode.
		 * @param	pDisplayTarget : DisplayObject target to listen to EnterFrame events. Needs to be on stage.
		 * @param	pFrames : Total frame number to wait until handler call.
		 * @param	pHandler : Called when the frame number is reached.
		 * @param	pHandlerParams : Handler parameters as array.
		 * @param	pDirectIfNoStage : Directly call handler if DisplayObject is null or not attached to stage. Permit to avoid pepory leaks with the handler.
		 */
		public static function wait (pDisplayTarget:DisplayObject, pFrames:uint, pHandler:Function, pHandlerParams:Array = null, pDirectIfNoStage:Boolean = true):void
		{
			// Si on a n'a pas de handler on quitte
			if (pHandler == null)
				return;
			
			// Appelé a chaque frame
			function waitTick (event:Event = null):void
			{
				// Si le nombre de frames est écoulé
				if (--pFrames == 0 || event == null)
				{
					// Ne plus écouter les frames et les suppressions
					pDisplayTarget.removeEventListener(Event.ENTER_FRAME, waitTick);
					pDisplayTarget.removeEventListener(Event.REMOVED_FROM_STAGE, waitTick);
					
					// Appeler le handler
					pHandler.apply(pDisplayTarget, pHandlerParams);
				}
				else if (event.type == Event.REMOVED_FROM_STAGE)
				{
					// Supprimer les listeners si le clip est supprimé
					pDisplayTarget.removeEventListener(Event.ENTER_FRAME, waitTick);
					pDisplayTarget.removeEventListener(Event.REMOVED_FROM_STAGE, waitTick);
				}
			}
			
			// Si on a besoin d'attendre quelques frames
			if (pFrames > 0 && (pDisplayTarget.stage != null || !pDirectIfNoStage))
			{
				// Ecouter les frames sur le clip
				pDisplayTarget.addEventListener(Event.ENTER_FRAME, waitTick);
				pDisplayTarget.addEventListener(Event.REMOVED_FROM_STAGE, waitTick);
			}
			else
			{
				// On lance directement
				waitTick();
			}
		}
		
		/**
		 * Redimentionner une composant par rapport à son parent.
		 * @param	pDisplayObject : Le displayObject à redimentionner
		 * @param	pLetterBox : Le displayObject ne laissera pas de marge si true, le displayObject sera affiché en entier si false
		 * @param	pCenter : Center le displayObject dans son parent
		 */
		public static function insideParent (pDisplayObject:Video, pLetterBox:Boolean = false, pCenter:Boolean = true):void
		{
			// Cibler le parent
			var parent:DisplayObjectContainer = pDisplayObject.parent;
			
			// Si on a un parent
			if (parent != null)
			{
				// Calculer les ratios
				var parentRatio:Number = parent.width / parent.height;
				var childRatio:Number = pDisplayObject.width / pDisplayObject.height;
				
				if (
						// Si le parent a un ratio > au ratio du child en letterBox
						(parentRatio > childRatio && pLetterBox)
						||
						// Ou l'inverse
						(parentRatio < childRatio && !pLetterBox)
					)
				{
					pDisplayObject.width = parent.width;
					pDisplayObject.height = parent.width / childRatio;
				}
				
				else if (
						// Si le parent a un ratio < au ratio du child en letterBox
						(parentRatio < childRatio && pLetterBox)
						||
						// Ou l'inverse
						(parentRatio > childRatio && !pLetterBox)
					)
				{
					pDisplayObject.height = parent.height;
					pDisplayObject.width = parent.height * childRatio;
				}
				
				// Les 2 displayObjects ont le même ratio
				else
				{
					// On applique
					pDisplayObject.width = parent.width;
					pDisplayObject.height = parent.height;
				}
				
				// Si on doit centrer le child
				if (pCenter)
				{
					pDisplayObject.x = (parent.width - pDisplayObject.width) / 2;
					pDisplayObject.y = (parent.height - pDisplayObject.height) / 2;
				}
			}
			else
			{
				// Déclancher une erreur, on a besoin du parent
				throw new SwappUtilsError("DiplayObjectUtils.insideParent", "pDisplayObject.parent can't be null to set the size.");
			}
		}
	}
}