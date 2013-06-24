package fr.swapp.core.dependences 
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * @author ZoulouX 
	 */
	public class DependencesManager implements IDependencesManager
	{
		/**
		 * All DependencesManager instances
		 */
		protected static var __instances			:Array 		= [];
		
		/**
		 * Get a DependencesManager instance. Instances are stored by name.
		 * @param	pName : Name of instance to get. If null, default will be returned
		 * @return : DependencesManager instance
		 */
		public static function getInstance (pName:String = "default"):DependencesManager
		{
			// Si l'instance avec ce nom n'existe pas
			if (!(pName in __instances))
			{
				// Créer l'instance
				new DependencesManager(new MultitonKey(), pName);
			}
			
			// Retourner l'instance avec ce nom
			return __instances[pName];
		}
		
		
		/**
		 * Les dépendences
		 */
		protected var _dependences					:Dictionary;
		
		/**
		 * Les concrêtes
		 */
		protected var _concretes					:Dictionary;
		
		/**
		 * Le nom du manager de dependences
		 */
		protected var _name							:String;
		
		
		/**
		 * Récupérer les dépendences.
		 * Dictionnaire avec classe en clé et objet associatif des dépendances en valeur.
		 */
		public function get dependences ():Dictionary { return _dependences; }
		
		/**
		 * Récupérer les concrêtes.
		 * Dictionnaire avec classe en clé et concrête en valeur.
		 */
		public function get concretes ():Dictionary { return _concretes; }
		
		/**
		 * Le nom du manager de dependences
		 */
		public function get name ():String { return _name; }
		
		
		/**
		 * Le constructeur
		 * @param	pWeekReference : Si les références aux classes sont faibles
		 */
		public function DependencesManager (pMultitonKey:MultitonKey, pName:String, pWeekReference:Boolean = false)
		{
			// Vérifier la création du multiton
			if (pMultitonKey == null)
			{
				throw new SwappError("DependencesManager.constructor", "Direct instancations are not allowed, please use DependencesManager.getInstance instead.");
			}
			else
			{
				// Enregistrer l'instance
				__instances[pName] = this;
				
				// Enregistrer le nom
				_name = pName;
				
				// Créer les dicos
				_dependences = new Dictionary(pWeekReference);
				_concretes = new Dictionary(pWeekReference);
			}
		}
		
		/**
		 * Ajouter une dépendance
		 * @param	pClass : La classe qui va recevoir des dépendances
		 * @param	pDependences : La liste des dépendances pour cette classe. En clé la propriété sur laquelle injecter, en valeur : La classe ou la concrête à injecter.
		 */
		public function addDependences (pClass:Class, pDependences:Object = null):void 
		{
			// Enregistrer
			_dependences[pClass] = pDependences;
		}
		
		/**
		 * Récupérer les dépendances d'une classe
		 * @param	pClass : La classe
		 */
		public function getDependences (pClass:Class):Object 
		{
			return _dependences[pClass];
		}
		
		/**
		 * Supprimer une dépendance
		 * @param	pClass : La classe qui ne va plus recevoir de dépendances
		 */
		public function removeDependences (pClass:Class):void 
		{
			// Effacer
			_dependences[pClass] = null;
			delete _dependences[pClass];
		}
		
		/**
		 * Mapper une concrête (sera utilisée pour chaque demande de son type de classe)
		 * @param	pClass : La classe exacte sur laquelle sera utilisée la concrête
		 * @param	pConcrete : La concrête. Si une classe ou rien n'est passé, la classe sera instancée à la demande EN SINGLETON.
		 * @param	pCustomDependences : La liste (associative) des propriétés du host (en clé) qui vont accueillir les concrêtes (leur classe en valeur) instanciées et injectées. (si null, alors la liste des dépendances sera récupérée depuis la manager)
		 */
		public function addConcrete (pClass:Class, pConcrete:* = null, pCustomDependences:Object = null):void
		{
			// Si la concrête est nulle
			if (pConcrete == null)
			{
				// Spécifier qu'on a besoin d'une instance à la demande en plaçant 0
				// On en profite pour spécifier les dépendances custom
				_concretes[pClass] = [0, pCustomDependences];
			}
			else
			{
				// Enregistrer la concrête
				_concretes[pClass] = pConcrete;
				
				// Si on a une concrête et des dépendances perso
				if (pCustomDependences != null)
				{
					// On injecte nos dépendances perso sur la concrête
					inject(_concretes[pClass], pCustomDependences);
				}
			}
		}
		
		/**
		 * Mapper une concrête (sera utilisée pour chaque demande de son type de classe)
		 * @param	pClass : La classe associée à une concrête
		 */
		public function getConcrete (pClass:Class):Object
		{
			// Instancier / retourner
			return instanciate(pClass);
		}
		
		/**
		 * Supprimer une concrête
		 * @param	pClass : La classe de la concrête
		 */
		public function removeConcrete (pClass:Class):void
		{
			// Effacer
			_dependences[pClass] = null;
			delete _dependences[pClass];
		}
		
		/**
		 * Instancier une classe et y injecter les dépendances automatiquement
		 * @param	pClass : La classe de la concrête à créer
		 * @return : La concrête instanciée
		 */
		public function instanciate (pClass:Class):Object
		{
			// Si on a cette classe dans les concrêtes
			if (_concretes[pClass] != null)
			{
				// Les dépendances à injecter
				var dependencesToInject:Object;
				
				// Vérifier si la concrête doit être instancée
				if (!(_concretes[pClass] is pClass) && _concretes[pClass] is Array)
				{
					// Enregistrer les dépendances à injecter
					dependencesToInject = _concretes[pClass][1];
					
					// Vérifier si on a une classe pour la concrête
					if (_concretes[pClass][0] is Class)
					{
						_concretes[pClass] = new _concretes[pClass][0] ();
					}
					else if (_concretes[pClass][0] == 0)
					{
						_concretes[pClass] = new pClass ();
					}
					
					// Si on a des trucs à injecter
					if (dependencesToInject != null)
					{
						// on injecte dans notre nouvelle instance
						inject(_concretes[pClass], dependencesToInject);
					}
				}
				
				// On retourne la concrête
				return _concretes[pClass];
			}
			else
			{
				// Instancier directement
				var instance:Object = new pClass ();
				
				// Essayer d'injecter
				inject(instance);
				
				// Retourner
				return instance;
			}
		}
		
		/**
		 * Récupérer les dépendances d'un objet. Cette fonction est récursive au niveau de l'héritage des classes.
		 * @param	pObject : L'objet
		 */
		public function getDependencesForObject (pObject:*):Object 
		{
			// Récupérer le nom de classe
			var currentClass:* = getQualifiedClassName(pObject);
			
			// Toutes les dépendances
			var allDependences:Object = { };
			
			// Les dépendances de la boucle
			var currentDependences:Object;
			
			// L'incrément pour parcourir les dépendances
			var i:*;
			
			// Si le nom de la classe a été trouvé
			while (currentClass != null && currentClass != "null")
			{
				// Cibler les dépendences
				currentDependences = _dependences[getDefinitionByName(currentClass)];
				
				// On regarde si ce nom de classe a des dépendences
				if (currentDependences != null)
				{
					// Parcourir ces dépendances
					for (i in currentDependences)
					{
						// Si la dépendance n'existe pas déjà (le plus concrêt est le plus prioritaire)
						if (allDependences[i] == null)
						{
							// Ajouter cette dépendance
							allDependences[i] = currentDependences[i];
						}
					}
				}
				
				// On essaye aussi de récupérer les dépendances de la Superclasse
				currentClass = getQualifiedSuperclassName(getDefinitionByName(currentClass));
			}
			
			// Retourner toutes les dépendences
			return allDependences;
		}
		
		/**
		 * Injecter les dépendances automatiquement sur un objet
		 * @param	pObject : L'objet a injecter
		 * @param	pCustomDependences : La liste (associative) des propriétés du host (en clé) qui vont accueillir les concrêtes (leur classe en valeur) instanciées et injectées. (si null, alors la liste des dépendances sera récupérée depuis la manager)
		 * @param	pRecursivity : La récursivité (-1 pour infini)
		 * @param	pTempConcretes : Les concrêtes a utiliser sur l'injection au premier niveau.
		 */
		public function inject (pObject:*, pCustomDependences:Object = null, pRecursivity:int = -1, pTempConcretes:Array = null):void 
		{
			// Si l'objet source n'est pas null
			if (pObject != null)
			{
				// Récupérer les dépendences depuis les paramètres ou sinon depuis la liste des dependances
				var dependencesObject:Object = pCustomDependences == null ? getDependencesForObject(pObject) : pCustomDependences;
				
				// Parcourir les dépendances à injecter
				for (var i:String in dependencesObject)
				{
					// Vérifier si on a une classe à injecter ou une concrête
					if (dependencesObject[i] is Class)
					{
						// On s'apprête a injecter une classe donc vérifier si on a pas des concrêtes temporaires
						if (pTempConcretes != null)
						{
							// Parourir les concrêtes temporaires
							for each (var tempConcrete:Object in pTempConcretes)
							{
								// Vérifier si la classe de cette concrête temporaire est la même classe que la dépendence
								if (getDefinitionByName(getQualifiedClassName(tempConcrete)) == dependencesObject[i])
								{
									// Injecter la concrête temporaire
									pObject[i] = tempConcrete;
								}
							}
						}
						
						// On instancie la concrête si on a pas déjà un truc
						if (pObject[i] == null)
							pObject[i] = instanciate(dependencesObject[i]);
					}
					else
					{
						// On applique directement la concrête
						pObject[i] = dependencesObject[i];
					}
					
					// Si l'objet injecté n'est pas null
					if (pObject[i] != null)
					{
						// Si le conteneur est IInjectable
						if (pObject is IInjectable)
						{
							// On signale qu'on a injecté un élément
							(pObject as IInjectable).valueInjected(i, pObject[i]);
						}
						
						// Et si on encore de la récursivité
						if (pRecursivity != 0)
						{
							// Injecter aussi la variable injectée
							inject(pObject[i], null, pRecursivity - 1);
						}
					}
				}
				
				// Si le conteneur est IInjectable
				if (pObject is IInjectable)
				{
					// On signale qu'on a injecté tous les éléments
					(pObject as IInjectable).valuesInjected();
				}
			}
		}
	}
}

/**
 * Private key to secure multiton providing.
 */
internal class MultitonKey {}