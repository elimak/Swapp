package fr.swapp.core.data.parse 
{
	/**
	 * Les imports
	 */
	import flash.events.OutputProgressEvent;
	import fr.swapp.core.data.collect.IDataCollection;
	import fr.swapp.core.data.items.IDataItem;
	import fr.swapp.core.data.parse.IDataParser;
	import fr.swapp.core.errors.SwappError;
	import fr.swapp.core.log.Log;
	
	/**
	 * Permet de parser des données brutes en IDataItem.
	 * Prend en charge les sources AMF, JSON et XML.
	 * Permet d'utiliser les adapteurs pour parser des données de structure différente.
	 * @author ZoulouX
	 */
	public class DataParser implements IDataParser
	{
		/**
		 * Remplir une collection avec les données d'une remote
		 * /!\ Attention, cette fonction est récursive!
		 * Il faut faire attention avec les références croisées, qui peuvent planter le script.
		 * @param	pData : Les données préparées de la remote.
		 * @param	pType : Le type à récupérer au premier niveau des données pour remplir la collection.
		 * @param	pRecursive : Le degrès de récursivité. Laisser à -1 pour une récursivité infinie.
		 */
		public static function feedCollection (pCollection:IDataCollection, pData:*, pType:Class, pRecursive:int = -1, pResetCollection:Boolean = false):void
		{
			// Si la collection est null
			if (pCollection == null)
			{
				throw new SwappError("DataParser.feedCollection", "Collection to feed is null.");
				return;
			}
			
			// Si les données sont null
			else if (pData == null)
			{
				throw new SwappError("DataParser.feedCollection", "Data to feed in collection is null.");
				return;
			}
			
			// Vérouiller la collection (pour qu'elle n'envoie pas d'events)
			pCollection.lock();
			
			// Remettre la collection à 0
			if (pResetCollection)
				pCollection.clear();
			
			// On appèle la méthode protégée en récursif
			internalFeedCollection(pCollection, pData, pType, pRecursive);
			
			// Dévérouiller la collection (pour qu'elle n'envoie pas d'events)
			pCollection.unlock();
		}
		
		/**
		 * Idem qu'au dessus :)
		 */
		protected static function internalFeedCollection (pCollection:IDataCollection, pData:*, pType:Class, pRecursive:int = -1):void
		{
			// Vérifier que les données sont "parsables"
			if (typeof(pData) == "object" || typeof(pData) == "array")
			{
				// Parser les données
				for each (var dataItem:* in pData)
				{
					// Récupérer ceux qui sont du type défini, sinon on renvoie dans la moulinette
					if (dataItem is pType && dataItem is IDataItem)
					{
						// Ajouter à la collection, et ne pas chercher plus en profondeur.
						pCollection.add(dataItem);
					}
					else if (pRecursive != 0)
					{
						// Chercher en récursivité. Décrémenter le niveau de récursivité.
						internalFeedCollection(pCollection, dataItem, pType, pRecursive - 1);
					}
				}
			}
		}
		
		
		/**
		 * Les items à parser
		 */
		protected var _items					:Array					= [];
		
		/**
		 * Les adapters d'item
		 */
		protected var _adapters					:Array					= [];
		
		/**
		 * Parser de manière stricte
		 */
		protected var _strict					:Boolean				= true;
		
		/**
		 * Récupérer la listes des items à parser
		 */
		public function get items ():Array { return _items; }
		
		/**
		 * Récupérer la liste des adapteurs
		 */
		public function get adapters ():Array { return _adapters; }
		
		/**
		 * Parser de manière stricte (pas d'erreur si on est pas en stricte)
		 */
		public function get strict ():Boolean { return _strict; }
		public function set strict (value:Boolean):void 
		{
			_strict = value;
		}
		
		
		/**
		 * Le constructeur.
		 * Le DataParser permet de convertir des données brutes en DataItems compatibles avec les DataCollection.
		 * @param	pStrictMode : Mode stricte (pas d'erreurs déclanchées si false)
		 */
		public function DataParser (pStrictMode:Boolean = true)
		{
			_strict = pStrictMode;
		}
		
		/**
		 * Ajouter un type d'item à parser. Cet item doit implémenter IDataItem
		 * @param	pItemName : Le nom (exemple "News")
		 * @param	pItemClass : La classe associée (exemple NewsItem)
		 */
		public function addItemType (pItemName:String, pItemClass:Class, pAdapters:Object = null):void 
		{
			// Ajouter l'item dans le tableau associatif
			_items[pItemName] = pItemClass;
			
			// Créer l'objet des adapteurs associé
			_adapters[pItemName] = { };
			
			// Inverser le tableau des adapteurs (clef = valeur et vice versa)
			if (pAdapters != null)
			{
				// Parcourir les adapteurs
				for (var name:String in pAdapters)
				{
					// Essayer d'inverser, si ça coince c'est que les adapteurs sont mal formatés
					try
					{
						// Clef = valeur, valeur = clef
						_adapters[pItemName][String(pAdapters[name])] = name;
					}
					catch (e:Error)
					{
						// Oups
						throw new SwappError("DataParser.addItemType", "Bad Adapter format, only string values are allowed.");
					}
				}
			}
		}
		
		/**
		 * Effacer un item par son nom.
		 * @param	pItemName : Le nom de l'item
		 */
		public function removeItemType (pItemName:String):void
		{
			// Effacer l'élément dans le tableau
			_items[pItemName] = null;
			delete _items[pItemName];
			
			// Virer l'adapteur
			_adapters[pItemName] = null;
			delete _adapters[pItemName];
		}
		
		/**
		 * Permet de parser le résultat d'une requête.
		 * Les types ajouté par les méthodes addParseType seront automatiquement castés lorsqu'un objet du même nom sera rencontré.
		 * Attention, cette méthode est récursive, il est conseillé de l'utiliser dans un bloc de test try catch.
		 * @param	pData : Les données brutes, peut provenir d'un service JSON AMF ou XML
		 * @return : Les données parsées avec les items
		 */
		public function parse (pData:*, pClass:Class = null):*
		{
			// L'item XML en train d'être parsé
			var xmlItem					:XML;
			
			// Le nom adapté de noeud en cours
			var nodeName				:String;
			
			// La liste d'items de sortie
			var listOut					:Array;
			
			// Si l'item à été parsé ou s'il est toujours natif
			var verified				:Boolean;
			
			// L'itérateur des items à parser
			var iItem					:String;
			
			// L'itérateur des adapteurs
			var iAdapter				:String;
			
			// L'itérateur de données pour le parse d'objet
			var iData					:String;
			
			// Les adapteurs courrant
			var parseAdapters			:Object;
			
			// La liste des éléments XML à parser
			var allElements				:XMLList;
			
			// L'objet de sortie, abstrait
			var out						:*;
			
			// Parser les noeuds XML en profondeur
			var splitNodeName			:Array;
			
			// L'itérateur pour le parsing de collection dans les adapters
			var adapterIterator			:String;
			
			// Si c'est de l'XML, on prépare pour le parse
			if (pData is XML || pData is XMLList)
			{
				// Cibler le premier si on est sur une liste
				if (pData is XMLList)
					pData = (pData[0] as XML)
				
				// Vérifier si cet XML n'a pas de mappage
				if (pClass == null)
				{
					// La liste des objets
					listOut = [];
					
					// Récupérer la liste des éléments
					allElements = (pData as XML).elements();
					
					// Parcourir les élément de l'XML
					for each (xmlItem in allElements)
					{
						// L'objet contenant l'item
						out = { };
						
						// Ce noeud n'est pas encore vérifié
						verified = false;
						
						// Parcourir la liste des items
						for (iItem in _items) 
						{
							// Vérifier si un élément XML porte le même nom qu'un item
							// On s'il contient un type explicite
							if (iItem == xmlItem.name() || iItem == xmlItem.@_explicitType || iItem == xmlItem._explicitType)
							{
								// Essayer de parser l'objet
								try
								{
									out[xmlItem.name()] = parse(xmlItem, _items[iItem]);
								}
								catch (e:Error)
								{
									showErrorMessage(iItem, e);
								}
								
								// Ce noeud à été vérifié
								verified = true;
								
								// Casser
								break;
							}
						}
						
						// S'il n'a pas été vérifier
						if (!verified)
						{
							// Chercher plus en profondeur
							out[xmlItem.name()] = parse(xmlItem);
						}
						
						// Ajouter ce noeud au tableau
						listOut.push(out);
					}
					
					// Retourner la liste
					return listOut;
				}
				
				// Si c'est un tableau
				else if (pClass == Array)
				{
					// S'il y a plusieurs éléments
					if (pData.hasComplexContent())
					{
						// Créer le tableau
						out = [];
						
						// Récupérer la liste des enfants
						var children:XMLList = pData.children();
						
						// Parcourir cette liste
						for each (var child:XML in children)
						{
							// Ajouter chaque child
							out.push(child.toString());
						}
					}
					else
					{
						// Splitter sur les virgules
						out = pData.toString().split(",");
					}
					
					// Retourner le tableau de sortie
					return out;
				}
				else
				{
					// Créer l'objet mappé
					out = new pClass () as IDataItem;
					
					// Les adapteurs
					parseAdapters = {};
					
					// Parcourir la liste des items
					for (iItem in _items)
					{
						// S'il y en a un du même type que l'item créé, on récupère alors ses adapters
						if (_items[iItem] == pClass && _adapters[iItem] != null)
						{
							// On récupère les adapters
							parseAdapters = _adapters[iItem];
							
							// On arrête de chercher
							break;
						}
					}
					
					// Récupérer la liste des éléments
					allElements = (pData as XML).attributes();
					
					// Récupérer tous les attributs
					for each (xmlItem in allElements)
					{
						// Récupérer le nom de l'attribut
						nodeName = xmlItem.name();
						
						// Parcourir les adapteurs
						for (iAdapter in parseAdapters)
						{
							// Si une adaptation est à faire, on remplace juste le nom par sa référence pour la suite
							if (nodeName == iAdapter)
								nodeName = parseAdapters[iAdapter];
						}
						
						// Essayer de parser
						try
						{
							out[nodeName] = parseByType(out[nodeName], xmlItem.toString());
						}
						catch (e:Error)
						{
							showErrorMessage(nodeName, e);
						}
					}
					
					// Récupérer la liste des éléments
					allElements = (pData as XML).elements();
					
					// Récupérer tous les noeuds
					for each (xmlItem in allElements)
					{
						// Récupérer le nom du noeud pour les adapteurs
						nodeName = xmlItem.name();
						
						// Parcourir les adapteurs
						for (iAdapter in parseAdapters)
						{
							// Si une adaptation est à faire, on remplace juste le nom par sa référence pour la suite
							// Vérifier si on a un jocker
							if (nodeName == iAdapter || iAdapter == "*")
								nodeName = parseAdapters[iAdapter];
						}
						
						// Si le noeud est complèxe c'est sûrement un objet
						// Vérifier aussi s'il a des arguments
						if (xmlItem.hasComplexContent() || xmlItem.attributes().length() > 0)
						{
							// Ce noeud n'est pas encore vérifié
							verified = false;
							
							// Vérifier si on est dans une collection
							// Et si la collection a un type forcé
							// Et si le nom de l'adapteur correspond bien au nom du noeud (vérifier le jocker)
							//if (out[nodeName] != null && out[nodeName] is IDataCollection && (out[nodeName] as IDataCollection).dataType != null && (parseAdapters[xmlItem.name()] == nodeName || parseAdapters["*"] == nodeName))
							if (out[nodeName] != null && out[nodeName] is IDataCollection && (out[nodeName] as IDataCollection).dataType != null)// && (parseAdapters[xmlItem.name()] == nodeName || parseAdapters["*"] == nodeName))
							{
								// TODO : Virer les try / catch du parser
								// TODO : Documenter l'histoire des adapters et des colections
								
								// Parser / Ajouter
								try
								{
									// Parcourir le premier niveau
									for each (var iXmlCollection:XML in xmlItem.children())
									{
										// Parser l'item grâce à l'adapteur, et l'ajoute dans la collection
										(out[nodeName] as IDataCollection).add(parse(iXmlCollection, (out[nodeName] as IDataCollection).dataType) as IDataItem);
									}
									
									// Ce noeud à été vérifié
									verified = true;
								}
								catch (e:Error)
								{
									showErrorMessage(nodeName, e);
								}
							}
							else
							{
								// Parcourir la liste des items
								for (iItem in _items)
								{
									// Vérifier si un élément XML porte le même nom qu'un item
									//if (xmlItem.name() == iItem || xmlItem.name() == nodeName)
									if (xmlItem.name() == iItem)
									{
										// TODO : WTF ici ?!!
										
										// Essayer d'ajouter normalement
										try
										{
											// Ajouter et parser ce noeud
											out[nodeName] = parse(xmlItem, _items[iItem]);
											
											// Ce noeud à été vérifié
											verified = true;
										}
										catch (e:Error)
										{
											showErrorMessage(iItem, e);
										}
										
										// On arrête
										break;
									}
								}
							}
							
							// S'il n'a pas été vérifier, chercher plus en profondeur
							if (!verified)
							{
								out[nodeName] = parseByType(out[nodeName], xmlItem);
							}
						}
						else
						{
							// Rien a parser, on ajoute en castant en string
							out[nodeName] = parseByType(out[nodeName], xmlItem.toString());
						}
					}
					
					// Retourner l'item
					return out;
				}
			}
			else if (typeof(pData) == "object")
			{
				// Créer l'objet des adapters
				parseAdapters = { };
				
				// Vérifier si on doit mapper avec une classe
				if (pData is Array)
				{
					out = [ ];
				}
				else if (pClass != null)
				{
					// Instancier l'objet de type IDataItem
					out = new pClass () as IDataItem;
					
					// Parcourir la liste des items
					for (iItem in _items)
					{
						// S'il y en a un du même type que l'item créé, on récupère alors ses adapters
						if (_items[iItem] == pClass && _adapters[iItem] != null)
							parseAdapters = _adapters[iItem];
					}
				}
				else
				{
					out = { };
				}
				
				// Parcourir l'objet à mapper
				for (iData in pData)
				{
					// Le nom du noeud
					nodeName = iData;
					
					// Parcourir les adapteurs
					for (iAdapter in parseAdapters)
					{
						// Si une adaptation est à faire, on remplace juste le nom par sa référence pour la suite
						if (nodeName == iAdapter || iAdapter == "*")
							nodeName = parseAdapters[iAdapter];
					}
					
					// Non vérifié pour le momen
					verified = false;
					
					// Vérifier si on est dans une collection
					// Et si la collection a un type forcé
					// Et si le nom de l'adapteur correspond bien au nom du noeud (vérifier le jocker)
					if (out[nodeName] != null && out[nodeName] is IDataCollection && ([nodeName] as IDataCollection).dataType != null && (parseAdapters[iData] == nodeName || parseAdapters["*"] == nodeName))
					{
						// Vérifier si c'est un tableau qui contient plusieurs objets
						// Sinon, si c'est un objet, on prend quand même
						if  (
								(pData[iData] is Array && (pData[iData] as Array).length > 0)
								||
								(!(pData[iData] is Array) && typeof(pData[iData]) == "object")
							)
						{
							// On parcour ce tableau
							for (adapterIterator in pData[iData])
							{
								// Essayer de parser le premier objet
								try
								{
									// On ajoute chacun des éléments
									(out[nodeName] as IDataCollection).add(parse(pData[iData][adapterIterator], (out[nodeName] as IDataCollection).dataType));
								}
								catch (e:Error)
								{
									// Ca ne marche pas, on essaye une autre méthode
									feedCollection(out[nodeName] as IDataCollection, parse(pData[iData]), (out[nodeName] as IDataCollection).dataType);
									
									// On casse la boucle
									break;
								}
							}
							
						}
						
						// Ce noeud à été vérifié
						verified = true;
					}
					else
					{
						// Vérifier le type de chaque child
						for (iItem in _items)
						{
							// Vérifier si cet item est à parser
							// Vérifier si on a un _explicitType
							if (iItem == iData || (pData[iData] != null && typeof(pData[iData]) == "object" && pData[iData]["_explicitType"] != null && iItem == pData[iData]["_explicitType"]))
							{
								// Essayer
								try
								{
									// Parser en passant la classe de l'item
									out[nodeName] = parse(pData[iData], _items[iItem]);
									
									// Ce child est vérifié
									verified = true;
								}
								catch (e:Error)
								{
									showErrorMessage(nodeName, e);
								}
								
								// Casser
								break;
							}
						}
					}
					
					// Si ce child n'a pas été vérifier, le parser sans classmap
					if (!verified)
					{
						// Vérifier si c'est un DataItem
						if (out is Array)
						{
							// Parse récursif et ajout au tableau
							out.push(parse(pData[iData]));
						}
						else if (out is IDataItem)
						{
							// Parser selon le type et ajout dans l'objet
							out[nodeName] = parseByType(out[nodeName], pData[iData]);
						}
						else
						{
							// Parser et ajout dans l'objet
							out[nodeName] = parse(pData[iData]);
						}
					}
				}
				
				// Retourner l'objet de retour \o/
				return out;
			}
			else if (pClass == Number || pClass == uint || pClass == int)
			{
				// Parser le number en virgule flotante
				return parseFloat(pData);
			}
			else if (pClass == Date)
			{
				// Parser la date
				return parseDate(pData.toString());
			}
			else if (pClass == Boolean)
			{
				// Parser le boolean
				return (pData.toString().toLowerCase() == "true" || pData == true || pData == "1" || pData == "on" || pData == "ok")
			}
			else
			{
				// Retourner simplement la donnée si ce n'est pas un objet
				return pData;
			}
		}
		
		/**
		 * déclencher une erreur de parse
		 */
		protected function showErrorMessage (pElementName:String, pError:Error):void
		{
			// Formater le message d'erreur
			var message:String = "Parse Error {In " + pElementName + ", " + pError.errorID + ": " + pError.message + ", " + pError.name + "}";
			
			// Si c'est en mode stricte, on lève une erreur et on arrête le massacre
			if (_strict)
			{
				throw new SwappError("DataParser.parse", message);
			}
			else
			{
				Log.warning("DataParser.parse -> " + message);
			}
		}
		
		/**
		 * Permet de parser un objet selon le type d'un autre objet.
		 * Cette méthode permet de convertir chaque variable d'un item dans son type de base.
		 * @param	pValue : La valeur de base à observer pour le type
		 * @param	pToParse : La valeur à convertir
		 * @return : L'objet converti
		 */
		protected function parseByType (pValue:*, pToParse:*):Object
		{
			// Vérifier le type de pValue, parser pToParse selon le type
			if (pValue is Array)
			{
				// Tableau
				return parse(pToParse, Array);
			}
			else if (pValue is uint || pValue is int || pValue is Number)
			{
				// Nombre
				return parse(pToParse, Number);
			}
			else if (pValue is Date)
			{
				// Date
				return parse(pToParse, Date);
			}
			else if (pValue is Boolean)
			{
				// Booléen
				return parse(pToParse, Boolean);
			}
			else
			{
				// Inconnu
				return parse(pToParse);
			}
		}
		
		/**
		 * La méthode pour parser une date.
		 * Il est possible d'overrider cette méthode.
		 * @param	pData : La date en entrée au format String
		 * @return : La date parsée au format Date
		 */
		protected function parseDate (pData:String):Date
		{
			// Créer l'objet date
			var date:Date = new Date();
			
			// Remettre la date à 0 (pour date heure etc)
			date.setTime(0);
			
			// Vérifier le type de date
			// YYYY-MM-DD
			if (/([0-9]{2,4})-([0-9]{1,2})-([0-9]{1,2})/.test(pData))
			{
				// Splitter la chaine de caractères
				var splited:Array = pData.toString().split("-");
				
				// Vérifier le type de l'année, 1900 ou 2000
				if (splited[0].length < 4)
					splited[0] = (parseFloat(splited[0]) >= 70 ? "19" : "20") + splited[0];
				
				// Spécifier la date
				date.setFullYear(parseInt(splited[0], 10));
				date.setMonth(parseInt(splited[1], 10) - 1);
				date.setDate(parseInt(splited[2], 10));
			}
			else
			{
				// Sinon format timestamp
				date.setTime(parseFloat(pData) * 1000);
			}
			
			// Retourner la date
			return date;
		}
	}
}