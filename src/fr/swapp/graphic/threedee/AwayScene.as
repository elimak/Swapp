package fr.swapp.graphic.threedee
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.materials.MaterialBase;
	import com.lahautesociete.proto3D.modules.FocusPoint;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import fr.swapp.core.log.Log;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SView;
	import fr.swapp.input.delegate.IInputDelegate;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class AwayScene extends AwayCameraController implements IInputDelegate
	{
		/**
		 * Lorsque le composant est détruit
		 */
		protected var _onDisposed				:Signal						= new Signal();
		
		/**
		 * Le container de la scène
		 */
		protected var _root						:ObjectContainer3D			= new ObjectContainer3D();
		
		/**
		 * La vue 2D
		 */
		protected var _view2D					:SView;
		
		/**
		 * La vue 3D
		 */
		protected var _view3D					:View3D;
		
		
		/**
		 * La position de base pour chaque élément.
		 * Les données sont remplies une fois les meshs chargés.
		 */
		protected var _elementsBasePosition		:Dictionary						= new Dictionary(false);
		
		/**
		 * La liste des meshs à récupérer lors d'un chargement de model 3D.
		 */
		protected var _meshNames				:Object;
		
		/**
		 * Si la scène est chargée
		 */
		protected var _sceneLoaded				:Boolean;
		
		/**
		 * Le nombre d'assets à charger
		 */
		protected var _assetsToLoad				:uint;
		
		/**
		 * Le nombre d'assets chargés
		 */
		protected var _assetsLoaded				:uint;
		
		/**
		 * Les liste des points focus à activer
		 */
		protected var _focusNames				:Array							= [];
		
		/**
		 * La liste des points focus activés
		 */
		protected var _focusPoints				:Array							= [];
		
		
		/**
		 * Lorsque le composant est détruit
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		/**
		 * Le container de la scène
		 */
		public function get root ():ObjectContainer3D { return _root; }
		
		
		
		/**
		 * Le constructeur
		 */
		public function AwayScene () { }
		override protected function construct ():void { }
		
		/**
		 * Initialisation de tous les éléments qui constituent la scène.
		 * Les paramètres vont être enregistrés en référence.
		 * La séquence d'initialisation précise sera ensuite lancée.
		 */
		public function init (pView2D:SView, pView3D:View3D, pCamera:Camera3D):void
		{
			// Enregistrer les vues et la camera
			_view2D = pView2D;
			_view3D = pView3D;
			_camera = pCamera;
			
			// Ecouter les frames pour la boucle de rendu
			_view3D.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			// Ecouter le chargement des assets 3D
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, assetCompleteHandler);
			
			// Initialiser
			initCameras();
			initLights();
			initMaterials();
			initObjects();
			initScene();
			initUI();
			initListeners();
		}
		
		/**
		 * 1/7 : Initialiser les cameras de la scène 3D
		 */
		protected function initCameras ():void
		{
			
		}
		
		/**
		 * 2/7 : Initialiser les lumières de la scène 3D
		 */
		protected function initLights ():void
		{
			
		}
		
		/**
		 * 3/7 : Initialiser les matériaux de la scène 3D
		 */
		protected function initMaterials ():void
		{
			
		}
		
		/**
		 * 4/7 : Initialiser les objets de la scène 3D
		 */
		protected function initObjects ():void
		{
			
		}
		
		/**
		 * 5/7 : Initialiser la scène 3D
		 */
		protected function initScene ():void
		{
			
		}
		
		/**
		 * 6/7 : Initialiser l'interface utilisateur
		 */
		protected function initUI ():void
		{
			
		}
		
		/**
		 * 7/7 : Initialiser les listeners
		 */
		protected function initListeners ():void
		{
			
		}
		
		/**
		 * Un élément 3D a été chargé
		 */
		protected function assetCompleteHandler (event:AssetEvent):void 
		{
			// Si on est bien sur un mesh
			if (event.asset.assetType == AssetType.MESH)
			{
				// Cibler le mesh
				var loadedMesh:Mesh = (event.asset as Mesh);
				var i:String;
				
				// Le tableau partof
				var partOfArray:Array;
				
				// Si c'est un mesh qu'on doit garder
				if (loadedMesh.name in _meshNames)
				{
					// Afficher le log
					Log.notice("AwayScene.assetCompleteHandler", "Mesh " + loadedMesh.name + " loaded");
					
					// Cibler la représentation material de l'objet
					var objectConf:Object = _meshNames[loadedMesh.name];
					
					// Enregistrer la référence
					definePropertyOnConcrete("_" + loadedMesh.name, loadedMesh);
					
					// Lui appliquer son material
					if ("material" in objectConf)
					{
						loadedMesh.material = objectConf.material;
					}
					
					// Si on doit décaller l'objet
					if ("offset" in objectConf)
					{
						// Parcourir les propriétés de la conf de l'offset
						for (i in objectConf.offset)
						{
							// Appliquer l'offset
							loadedMesh[i] += objectConf.offset[i];
						}
					}
					
					// L'ajouter à la scène
					_root.addChild(loadedMesh);
					
					// Si ça fait partie d'un ensembre
					if ("partOf" in objectConf)
					{
						// Cibler le talbeau partOf
						partOfArray = getPropertyOnConcrete(objectConf.partOf) as Array;
						
						// On l'ajoute si le tableau existe
						if (partOfArray != null)
						{
							partOfArray.push(loadedMesh);
						}
					}
					
					// Ajouter la position de base
					saveObjectState(loadedMesh);
					
					// Si on doit cloner l'objet
					if ("duplicate" in objectConf)
					{
						// Cloner l'objet
						var clonedMesh:Mesh = loadedMesh.clone() as Mesh;
						
						// Parcourir les propriétés de la conf du clone
						for (i in objectConf.duplicate)
						{
							// Appliquer l'offset
							clonedMesh[i] += objectConf.duplicate[i];
						}
						
						// Enregistrer la référence en la différenciant
						definePropertyOnConcrete("_" + loadedMesh.name + "_2", clonedMesh);
						
						// L'ajouter à la scène
						_root.addChild(clonedMesh);
						
						// Si ça fait partie d'un ensembre
						if ("partOf" in objectConf)
						{
							// Cibler le talbeau partOf
							partOfArray = getPropertyOnConcrete(objectConf.partOf + "_2") as Array;
							
							// On l'ajoute si le tableau existe
							if (partOfArray != null)
							{
								partOfArray.push(clonedMesh);
							}
						}
						
						// Ajouter la position de base
						saveObjectState(clonedMesh);
					}
					
					// Un asset de plus chargé
					_assetsLoaded ++;
					
					// Signaler que le chargement à bougé
					sceneLoadingHandler(_assetsLoaded / _assetsToLoad);
					
					// Si on n'a plus rien à charger
					if (_assetsLoaded >= _assetsToLoad)
					{
						// Juste avant que la scène soit chargée
						beforeSceneLoadedHandler();
						
						// Tout est chargé
						_sceneLoaded = true;
						
						// Une fois que la scène est chargée
						sceneLoadedHandler();
					}
				}
				else
				{
					// Afficher le log
					Log.warning("AwayScene.assetCompleteHandler", "Mesh " + loadedMesh.name + " not found in meshNames configuration.");
				}
			}
			
			// Si on est sur un material
			else if (event.asset.assetType == AssetType.MATERIAL)
			{
				Log.notice("AwayScene.assetCompleteHandler", "Material " + (event.asset as MaterialBase).name + " loaded");
			}
			
			// Si on est sur une géometrie
			else if (event.asset.assetType == AssetType.GEOMETRY)
			{
				Log.notice("AwayScene.assetCompleteHandler", "Geometry " + (event.asset as Geometry).name + " loaded");
			}
			
			// Sinon on sait pô
			else
			{
				Log.warning("AwayScene.assetCompleteHandler", "Asset type " + event.asset.assetType + " not found");
			}
		}
		
		/**
		 * Sauvegarder la position d'un objet 3D
		 */
		public function saveObjectState (pMesh:Mesh):void
		{
			_elementsBasePosition[pMesh] = {
				x: 			pMesh.x,
				y: 			pMesh.y,
				z: 			pMesh.z,
				rotationX:	pMesh.rotationX,
				rotationY:	pMesh.rotationY,
				rotationZ:	pMesh.rotationZ,
				scaleX:		pMesh.scaleX,
				scaleY:		pMesh.scaleY,
				scaleZ:		pMesh.scaleZ
			};
		}
		
		/**
		 * La scène est en train de charger
		 */
		protected function sceneLoadingHandler (pLoadingRatio:Number):void
		{
			
		}
		
		/**
		 * Initialiser les points focus.
		 * Appelé lorsque la scène est chargée.
		 */
		protected function initFocusPoints ():void
		{
			
		}
		
		/**
		 * Juste avant que la scène soit chargée
		 */
		protected function beforeSceneLoadedHandler ():void
		{
			// Initialiser les points focus
			initFocusPoints();
			
			// Gestion des focusPoints
			manageFocusPoints();
			
			// Actualiser la visibilité des focus
			updateFocusVisibility();
		}
		
		/**
		 * La scène est chargée
		 */
		protected function sceneLoadedHandler ():void
		{
			// Relancer le playIn
			playIn();
		}
		
		/**
		 * Actualiser la visibilité des points de focus
		 */
		protected function updateFocusVisibility ():void
		{
			
		}
		
		/**
		 * Gestion des focusPoints
		 */
		protected function manageFocusPoints ():void
		{
			// Le point focus qui va être créé
			var focusObject:FocusPoint;
			
			// Parcourir les points focus à créer
			for each (var focusSource:Object in _focusNames)
			{
				// Créer le focusPoint correspondant à la description
				focusObject = new FocusPoint(
					// La référence vers la vue pour la projection
					_view3D,
					
					// Enregistrer la position 3D
					(focusSource.object as ObjectContainer3D),
					
					// Enregistrer le displayObject
					(focusSource.displayObject as DisplayObject),
					
					// Enregistrer les offsets s'ils sont donnés
					("offset3d" in focusSource ? focusSource.offset3d as Vector3D : null),
					("offset2d" in focusSource ? focusSource.offset2d as Point : null)
				);
				
				// Le nom du focus
				focusObject.name = focusSource.name;
				
				// Masquer par défaut
				focusObject.displayObject.visible = false;
				
				// Si on a un container 2D
				if ("container2d" in focusSource && focusSource.container2d is DisplayObjectContainer)
				{
					// Ajouter le displayObject au container 2D
					(focusSource.container2d as DisplayObjectContainer).addChild(focusObject.displayObject);
				}
				else
				{
					// Ajouter le displayObject à la vue 2D
					_view2D.addChild(focusObject.displayObject);
				}
				
				// Enregistrer le focusPoint
				_focusPoints.push(focusObject);
			}
		}
		
		/**
		 * Actualiser la position des focus
		 */
		protected function updateFocusPosition ():void
		{
			// La position qui va etre calculée
			var position:Point;
			
			// Parcourir les points focus
			for each (var focusPoint:FocusPoint in _focusPoints)
			{
				// Actualiser la position du clip 2D
				position = focusPoint.update();
				
				// Si c'est un composant swapp
				if (focusPoint.displayObject is SComponent)
				{
					// Placer avec left et top
					(focusPoint.displayObject as SComponent).rectPlace(position.x, position.y);
				}
				
				// Si c'est displayObject
				else
				{
					// Placer avec x et y
					focusPoint.displayObject.x = position.x;
					focusPoint.displayObject.y = position.y;
				}
			}
		}
		
		/**
		 * Boucle de rendu
		 */
		protected function enterFrameHandler (event:Event):void
		{
			
		}
		
		/**
		 * Animation d'intro
		 */
		public function playIn (pParams:Object = null, pEndHandler:Function = null):void
		{
			
		}
		
		/**
		 * Animation d'outro
		 */
		public function playOut (pParams:Object = null, pEndHandler:Function = null):void
		{
			
		}
		
		/**
		 * Permet de récupérer / définir une propriété sur une concrête.
		 * Doit être overridé
		 */
		protected function getPropertyOnConcrete (pPropertyName:String):*
		{
			return this[pPropertyName];
		}
		protected function definePropertyOnConcrete (pPropertyName:String, pValue:*):void
		{
			try
			{
				
				this[pPropertyName] = pValue;
			}
			catch (e:Error) { };
		}
		
		/**
		 * Destruction
		 */
		public function dispose ():void
		{
			// Ne plus écouter la boucle de rendu
			_view3D.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			// Ne plus écouter le chargement de ressources 3D
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, assetCompleteHandler);
			
			// Remettre le dico des éléments 3D à 0
			_elementsBasePosition = null;
		}
	}
}