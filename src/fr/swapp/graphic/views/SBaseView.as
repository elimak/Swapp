package fr.swapp.graphic.views
{
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	import fr.swapp.core.log.Log;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.errors.GraphicalError;
	import fr.swapp.utils.DisplayObjectUtils;
	import fr.swapp.utils.StringUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class SBaseView extends SComponent
	{
		/**
		 * All processed components
		 */
		protected var _components:Object = { };
		
		
		/**
		 * All processed components
		 */
		public function get components ():Object { return _components; }
		
		
		/**
		 * Constructor
		 */
		public function SBaseView ()
		{
			// Activer les styles
			_styleEnabled = true;
			
			// Lancer le sous-constructeur
			construct();
			
			// Rendu des composants abstract
			beforeBuildInterface();
			
			// Construire l'interface
			buildInterface();
		}
		
		/**
		 * Sub-constructor
		 */
		protected function construct ():void
		{
			
		}
		
		/**
		 * Abstract interface builder.
		 * Called just before buildInterface.
		 * Don't forget to call the super.
		 */
		protected function beforeBuildInterface ():void
		{
			
		}
		
		/**
		 * Build the interface.
		 * Add components here.
		 */
		protected function buildInterface ():void
		{
			
		}
		
		/**
		 * Setup components list. Will be added in order, key is used to store reference in this instance.
		 * Add a property "_" in a dynamic object to create a component with a specific type or instance.
		 * @param	pComponents : The component list (key is the name of the component, value is the component instance)
		 */
		protected function setupComponents (pComponents:Object):void
		{
			// On lance la gestion de composants récursive
			processComponents(this, pComponents);
		}
		
		/**
		 * Process components creation.
		 * @param	pParent : Component parent.
		 * @param	pComponents : The component list (key is the name of the component, value is the component instance)
		 */
		protected function processComponents (pParent:SComponent, pComponents:Object):void
		{
			// L'index des composants
			var index:uint;
			
			// Le composant ciblé et ses props
			var component	:SComponent;
			var value		:Object;
			var currentName	:String;
			
			// Parcourir les composants
			for (var i:String in pComponents)
			{
				// Cibler la valeur
				value = pComponents[i];
				
				// Le nom du composant
				currentName = i;
				
				// Si on est sur la propriété _
				// Ou si on est sur un truc null
				if (i == "_" || value == null)
				{
					// On l'ignore et passe au suivant
					continue;
				}
				
				// Si c'est bien un composant
				if (value is SComponent)
				{
					// Cibler l'instance du composant
					component = value as SComponent;
				}
				
				// Sinon si c'est un object dynamique
				else if (getQualifiedClassName(value) == "Object")
				{
					// Si on a une propriété _
					if ("_" in value)
					{
						// Si le _ est bien une instance de SComponent
						if (value["_"] is SComponent)
						{
							// Cibler l'instance
							value = value["_"];
						}
						
						// Vérifier si c'est une classe de SComponent
						else if (value["_"] is Class)
						{
							// Vérifier que l'objet créé soit bien un composant
							if (value is SComponent)
							{
								// On le cible
								component = value as SComponent;
							}
							else
							{
								// On signale le problème
								throw new GraphicalError("SBaseView.processComponents", "Bad _ type in component list. All components have to extends SComponent.");
								
								// Et on arrête le massacre
								break;
							}
						}
						
						// On ne sait pas ce que c'est
						else
						{
							// On signale le problème
							throw new GraphicalError("SBaseView.processComponents", "Bad use of the _ type property. Use this property only to describe component type to create.");
							
							// Et on arrête le massacre
							break;
						}
					}
					else
					{
						// Sinon créer un composant de base
						component = new SComponent();
					}
					
					// Parcourir les composants récursif
					processComponents(component, pComponents[i]);
				}
				
				// Sinon c'est rien de bon
				else
				{
					// On signale le problème
					throw new GraphicalError("SBaseView.processComponents", "Bad component " + i + " in components list. All components have to extends SComponent.");
					
					// Et on arrête le massacre
					break;
				}
				
				// Activer les styles sur ce component
				component.styleEnabled = true;
				
				// Si on a un nom
				// Et que la variable existe
				//trace("TRYING NAME", currentName, currentName != "", currentName in this);
				
				// Vérifier si la première lettre du nom est un dollar
				if (currentName != null && currentName != "" && currentName.charAt(0) == "$")
				{
					// Essayer d'ajouter la propriété à la vue
					if (currentName in this)
					{
						this[currentName] = component;
					}
					
					// Virer le dollar avant la définition du nom du composant
					currentName = currentName.substr(1, currentName.length - 1);
				}
				
				// Ajouter le composant en bas avec son nom
				component.into(pParent, 0, currentName);
			}
		}
	}
}