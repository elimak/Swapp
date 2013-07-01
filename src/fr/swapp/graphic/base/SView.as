package fr.swapp.graphic.base
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import fr.swapp.core.central.Central;
	import fr.swapp.core.dependences.DependencesManager;
	import fr.swapp.core.mvc.IView;
	import fr.swapp.core.navigation.IBootstrap;
	import fr.swapp.graphic.navigation.SNavigationStack;
	import fr.swapp.graphic.styles.IStyleData;
	import fr.swapp.utils.ClassUtils;
	import fr.swapp.utils.DisplayObjectUtils;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class SView extends SBaseView implements IView
	{
		/**
		 * Style data
		 */
		protected var _styleData							:IStyleData;
		
		/**
		 * Events from Central (eventName in key, handler in value)
		 */
		protected var _events								:Object;
		
		
		/**
		 * Get DisplayObject instance of this view
		 */
		public function get displayObject ():DisplayObjectContainer { return this; }
		
		/**
		 * Get the first SNavigationStack recursively to the stage.
		 */
		public function get navigationStack ():SNavigationStack
		{
			// Cibler la SNavigationStack parente
			return DisplayObjectUtils.getParentOfType(this, SNavigationStack) as SNavigationStack;
		}
		
		/**
		 * Get the first bootstrap recursively to the stage.
		 */
		public function get bootstrap ():IBootstrap
		{
			// Récupérer la navigationStack la plus proche
			var ns:SNavigationStack = navigationStack;
			
			// Retourner le bootstrap si on en a trouvé une sinon on retourne null
			return (ns != null ? ns.bootstrap : null);
		}
		
		
		/**
		 * Constructor
		 */
		public function SView ()
		{
			
		}
		
		
		/**
		 * Set style data class. Will be automatically added at init.
		 */
		protected function setStyleData (pStyleDataClass:Class, pWithClass:Class = null):void
		{
			// Si on n'a pas déjà un style
			if (_styleData == null)
			{
				// Si une classe est donnée
				if (pWithClass != null)
				{
					// Définir le nom de style par le nom de la classe donnée
					style(ClassUtils.getClassName(pWithClass));
				}
				else
				{
					// Définir le nom de style par le nom de classe de l'instance en cours
					style(ClassUtils.getClassNameFromInstance(this));
				}
				
				// Enregistrer l'instance
				_styleData = DependencesManager.getInstance().instanciate(pStyleDataClass) as IStyleData;
				
				// Lui passer le nom de la classe de base
				_styleData.baseClassName = _styleName;
				
				// Activer la prise en compte du style
				_styleData.init();
			}
		}
		
		/**
		 * Added to stage
		 */
		override protected function addedHandler (event:Event = null):void
		{
			// Appliquer le style si disponible
			if (_styleData != null)
			{
				SWrapper.getInstance().styleCentral.addStyleData(_styleData);
			}
			
			// Relayer
			super.addedHandler(event);
		}
		
		/**
		 * Set events via Central
		 */
		protected function setEvents (pEvents:Object):void
		{
			_events = (_events == null ? { } : _events);
			
			// Virer les anciens events
			disposeEvents();
			
			// Enregistrer
			ObjectUtils.extra(_events, pEvents);
			
			// Initialiser les nouveaux events
			initEvents();
		}
		
		/**
		 * Init events via Central
		 */
		protected function initEvents ():void
		{
			// Parcourir les events
			for (var i:String in _events)
			{
				Central.getInstance().listen(i, _events[i]);
			}
		}
		
		/**
		 * Dispose events via Central
		 */
		protected function disposeEvents ():void
		{
			// Parcourir les events
			for (var i:String in _events)
			{
				Central.getInstance().remove(i, _events[i]);
			}
		}
		
		/**
		 * Dispose
		 */
		override public function dispose ():void
		{
			// Supprimer le style si disponible
			if (_styleData != null)
			{
				SWrapper.getInstance(stage).styleCentral.removeStyleData(_styleData);
			}
			
			// Supprimer les events
			disposeEvents();
			
			// Relayer
			super.dispose();
		}
	}
}