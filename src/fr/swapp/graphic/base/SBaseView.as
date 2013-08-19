package fr.swapp.graphic.base
{
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
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
		 * Build the interface.
		 * Add components here.
		 */
		protected function buildInterface ():void
		{
			
		}
		
		/**
		 * Setup components list. Will be added in order, key is used to store reference in this instance.
		 * Add a property "type" in a dynamic object to create a component with a specific type.
		 * @param	pComponents : The component list (key is the name of the component, value is the component instance)
		 */
		protected function setupComponents (pComponents:Object):void
		{
			// On lance la gestion de composants récursive
			processComponents(this, pComponents, "$");
		}
		
		/**
		 * Process components creation.
		 * @param	pParent : Component parent.
		 * @param	pComponents : The component list (key is the name of the component, value is the component instance)
		 */
		protected function processComponents (pParent:SComponent, pComponents:Object, pCurrentName:String = ""):void
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
				
				// Créer le nom complet de ce composant (avec les parents)
				currentName = pCurrentName + StringUtils.capitalize(i);
				
				// Si on est sur la propriété type
				// Ou si on est sur un truc null
				if (i == "type" || value == null)
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
					// Si on a une propriété type
					if ("type" in value)
					{
						// Si le type est bien une classe
						if (value["type"] is Class)
						{
							// Créer un composant de ce type
							value = new value["type"];
							
							// Vérifier que l'objet créé soit bien un composant
							if (value is SComponent)
							{
								// On le cible
								component = value as SComponent;
							}
							else
							{
								// On signale le problème
								throw new GraphicalError("SBaseView.processComponents", "Bad 'type' in component list. All components have to extends SComponent.");
								
								// Et on arrête le massacre
								break;
							}
						}
						else
						{
							// On signale le problème
							throw new GraphicalError("SBaseView.processComponents", "Bad use of the 'type' property. Use this property only to describe component type to create.");
							
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
					processComponents(component, pComponents[i], currentName);
				}
				
				// Sinon c'est rien de bon
				else
				{
					// On signale le problème
					throw new GraphicalError("SBaseView.processComponents", "Bad component in components list. All components have to extends SComponent.");
					
					// Et on arrête le massacre
					break;
				}
				
				// Si une propriété du parent possède le nom du composant
				/*
				if (i in pParent)
				{
					// On les associes
					pParent[i] = component;
				}
				*/
				
				// Activer les styles sur ce component
				component.styleEnabled = true;
				
				// Si on a un nom
				// Et que la variable existe
				trace("TRYING NAME", currentName, currentName != "", currentName in this);
				
				if (currentName != null && currentName != "" && currentName in this)
				{
					this[currentName] = component;
				}
				
				// Ajouter le composant en haut avec son nom
				component.into(pParent, -1, i);
			}
		}
	}
}