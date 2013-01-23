package fr.swapp.graphic.styles
{
	import flash.utils.getQualifiedClassName;
	import fr.swapp.core.log.Log;
	import fr.swapp.core.roles.IDisposable;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * @author ZoulouX
	 */
	public class StyleCentral implements IDisposable
	{
		/**
		 * Les styles globaux
		 */
		protected var _styleData					:Object						= {};
		
		/**
		 * La liste des sélécteurs.
		 * En clé, le dernier élément des selecteurs.
		 * En valeur, un tableau contenant chaque sélécteur de cette clé.
		 */
		protected var _selectors					:Array						= [];
		
		/**
		 * Lorsque le style à changé
		 */
		protected var _onStyleChanged				:Signal						= new Signal();
		
		/**
		 * When disposed
		 */
		protected var _onDisposed					:Signal						= new Signal();
		
		
		/**
		 * Les styles globaux
		 */
		public function get styleData ():Object { return _styleData; }
		public function set styleData (value:Object):void
		{
			// Si on a des données
			if (value != null)
			{
				// Enregistrer
				_styleData = value;
				
				// Parser
				parseStyleData();
			}
		}
		
		/**
		 * Lorsque le style à changé
		 */
		public function get onStyleChanged ():Signal { return _onStyleChanged; }
		
		/**
		 * When disposed
		 */
		public function get onDisposed ():ISignal { return _onDisposed; }
		
		
		/**
		 * Le constructeur
		 */
		public function StyleCentral ()
		{
			// TODO : Vérifier le déclenchement des erreurs (essayer d'appliquer une valeur sur une fonction, etc)
			// TODO : Peut être faire un mode strict (Qui throw des error au lieu de log)
			
			// TODO : Voir si on peut pas intégrer les states? (Pratique pour le bouton)
			// TODO : Voir si on peut pas intégrer le name du DisplayObject?
			
			// TODO : Faire un sélécteur de DisplayObject style jQuery grâce aux algos déjà fait. Voir si le code peut être mutialisé.
			// TODO : Peut être qu'il faut composer l'outil de ciblage au styleCentral (SQuery.getInstance(stage) ? SWrapper.getInstance(stage).query ?)
			// TODO : Il faudra simplifier l'accès au stageWrapper car dans les controlleurs (par exemple) on n'a pas accès à stage.
			// TODO : Trouver un moyen de charger des stylesSheets à la volée (par exemple, une vue ajoute du style)
			// TODO : Ou alors faire une méthode addStyle() et faire plusieurs addStyles(MyViewStyle) et autres addStyle(MainUIStyle)
		}
		
		
		/**
		 * Parser les styles
		 */
		public function parseStyleData ():void
		{
			var styleSelector				:String;
			var styleSelectorSplitted		:Array;
			var selectorKey					:String;
			var pointIndex					:int;
			
			// Réinitialiser la liste des sélécteurs
			_selectors = [];
			
			// Parcourir les déclarations
			for (styleSelector in _styleData) 
			{
				// Splitter le sélécteur de cette déclaration
				styleSelectorSplitted = styleSelector.split(" ");
				
				// Prendre le dernier en clé
				selectorKey = styleSelectorSplitted[styleSelectorSplitted.length == 1 ? 0 : styleSelectorSplitted.length - 1];
				
				// Si cette clé n'était pas encore déclarée
				if (_selectors[selectorKey] == null)
				{
					// On la selectorKey
					_selectors[selectorKey] = [];
				}
				
				// On ajoute le selecteur sur cette clé
				_selectors[selectorKey].push(styleSelectorSplitted);
				
				
				// Récupérer la position du point
				pointIndex = selectorKey.indexOf(".");
				
				// Pas de point (-1), c'est juste un style
				// Point au début (0), c'est juste une classe
				if (pointIndex <= 0)
				{
					addSelectorKey(selectorKey, styleSelectorSplitted);
				}
				
				// Point au milieu (> 0), c'est les deux
				else
				{
					// Ajouter la classe
					addSelectorKey(selectorKey.substring(), styleSelectorSplitted);
					
					// Ajouter le style
					addSelectorKey(selectorKey, styleSelectorSplitted);
					
					// Et ajouter le tout
				}
			}
			
			// Signaler que le style a changé
			invalidateStyleData();
		}
		
		/**
		 * Ajouter une clé de sélécteur dans la liste rapide des sélécteurs.
		 * @param	pSelectorKey : La clé
		 * @param	pStyleSelectorSplitted : Le sélécteur complet, splitté.
		 */
		protected function addSelectorKey (pSelectorKey:String, pStyleSelectorSplitted:Array):void
		{
			// Si cette clé n'était pas encore déclarée
			if (_selectors[pSelectorKey] == null)
			{
				// On la déclare
				_selectors[pSelectorKey] = [];
			}
			
			// On ajoute le selecteur sur cette clé
			_selectors[pSelectorKey].push(pStyleSelectorSplitted);
		}
		
		/**
		 * Récupérer un style calculé pour un élément stylisable.
		 * @param	pTarget : L'élément dont on doit récupérer le style
		 */
		public function getComputedStyleFromStylable (pTarget:IStylable):Object
		{
			// Récupérer les styles appliqués sur chacun des parents
			// Récupérer le style correspondant et le retourner
			return getComputedStyleFromSignature(getStyleSignature(pTarget));
		}
		
		/**
		 * Récupérer un style calculé par une signature
		 * @param	pSignature : La signature
		 */
		public function getComputedStyleFromSignature (pSignature:Vector.<String>):Object
		{
			// Le style calculé
			var computedStyle:Object = {};
			
			// Récupérer la liste des sélécteurs qui correspondent à cette signature
			var selectors:Vector.<String> = getSelectorsFromSignature(pSignature);
			
			// Le sélécteur et le style en cours
			var selector:String;
			var style:Object;
			var i:String;
			
			// Parcourir les sélécteurs dans l'ordre
			for each (selector in selectors)
			{
				// Cibler le style
				style = _styleData[selector];
				
				// Parcourir le style
				for (i in style)
				{
					// Ajouter chaque propriété
					computedStyle[i] = style[i];
				}
			}
			
			// Retourner le style calculé
			return computedStyle;
		}
		
		/**
		 * Récupérer la liste des sélécteurs correspondant à une signature
		 */
		public function getSelectorsFromSignature (pSignature:Vector.<String>):Vector.<String>
		{
			// La liste des sélécteurs que l'on va retourner
			var validSelectors:Vector.<String> = new Vector.<String>;
			
			// Si la signature est invalide, on ne va pas plus loin
			if (pSignature == null || pSignature.length == 0)
				return validSelectors;
			
			// Récupérer la clé de la signature
			var signatureKey:String = pSignature[pSignature.length == 1 ? 0 : pSignature.length - 1];
			
			// Les éléments de signature
			var signatureKeyParts:Array = [signatureKey];
			
			// L'index de séparation entre la classe et le style
			var dotIndex:int = signatureKey.indexOf(".");
			
			// S'il y a un style
			if (dotIndex > 0 && dotIndex < signatureKey.length - 1)
			{
				// Ajouter la classe et le nom du style
				signatureKeyParts[1] = signatureKey.substring(0, dotIndex);
				signatureKeyParts[2] = signatureKey.substring(dotIndex, signatureKey.length);
			}
			
			
			// La partie de la clé de la signature en cours de traitement
			var currentSignatureKeyPart:String;
			
			// Les sélécteurs correspondant à la clé trouvée
			var selectors:Array 
			
			// Le selecteur
			var selector:Array;
			
			// Les variables d'itération (i pour le selecteur, j pour la signature)
			var i:int;
			var j:int;
			
			// Si l'élément d'un sélécteur à été trouvé dans la signature
			var selectorElementfound:Boolean;
			
			// Si le selecteur correspond à la signature
			var selectorOk:Boolean;
			
			// Les parties du sélécteur en cours
			var currentSelectorSplit:Array;
			
			// Parcourir les éléments de la signature
			var h:int = signatureKeyParts.length;
			while (--h >= 0)
			{
				// Cibler la partie du sélécteur
				currentSignatureKeyPart = signatureKeyParts[h];
				
				// Si cette partie de la clé du sélécteur correspond à un style
				if (currentSignatureKeyPart in _selectors)
				{
					// Les sélécteurs correspondant à la clé trouvée
					selectors = _selectors[currentSignatureKeyPart];
					
					// Parcourir les sélécteurs
					for each (selector in selectors)
					{
						// Placer les variables d'itérations à la fin des entités à parcourir
						i = selector.length;
						j = pSignature.length;
						
						// Par défaut le sélécteur est valide
						selectorOk = true;
						
						// Parcourir les éléments de ce selecteur
						while (i -- > 0)
						{
							// Par défaut cet élément n'a pas été trouvé
							selectorElementfound = false;
							
							// Parcourir les éléments de la signature
							while (j-- > 0)
							{
								// Si cet élément du selecteur est dans la signature
								if (pSignature[j] == selector[i])
								{
									// Alors on a trouvé
									selectorElementfound = true;
									break;
								}
								
								// Si notre sélécteur est en plusieurs parties
								else if (pSignature[j].indexOf(".") != 0)
								{
									// Récupérer la position du point
									dotIndex = selector[i].indexOf(".");
									
									// On coupe l'élément de la signature en deux
									currentSelectorSplit = pSignature[j].split(".");
									
									if (
											// Si c'est un style (point au début)
											(dotIndex == 0 && selector[i] == "." + currentSelectorSplit[1])
											||
											
											// Si c'est une classe (pas de point)
											(dotIndex == -1 && selector[i] == currentSelectorSplit[0])
										)
									{
										// Alors on a trouvé
										selectorElementfound = true;
										break;
									}
								}
							}
							
							// Si cet élément n'a pas été trouvé
							if (!selectorElementfound)
							{
								// Le selecteur n'est pas conforme
								selectorOk = false;
								break;
							}
						}
						
						// Si le selecteur est conforme
						if (selectorOk)
						{
							// On l'ajoute à la liste des sélécteurs
							validSelectors.push(selector.join(" "));
						}
					}
				}
			}
			
			// Retourner la liste des sélécteurs qu'on a trouvé
			return validSelectors;
		}
		
		/**
		 * Injecter un style dans un élément stylisable.
		 * @param	pTarget : L'élément sur lequel on va injecter le style. (cet objet n'est pas forcément IStylable)
		 */
		public function injectStyle (pTarget:Object, pStyle:Object):void
		{
			// Si on a un élément et un style
			if (pTarget != null && pStyle != null)
			{
				// La valeur
				var value:*;
				
				// Parcourir les propriétés de l'objet style
				for (var property:String in pStyle)
				{
					// Cibler la valeur
					value = pStyle[property];
					
					// Si la propriété existe bien sur cet objet
					if (property in pTarget)
					{
						// Si c'est un tableau
						if (value is Array && pTarget[property] is Function)
						{
							// Alors c'est un appel de méthode
							(pTarget[property] as Function).apply(pTarget, value);
						}
						
						// Si c'est un objet dynamique
						else if (getQualifiedClassName(value) == "Object")
						{
							// Alors on injecte en récursif
							injectStyle(pTarget[property], value);
						}
						
						// Sinon on injecte simplement
						else
						{
							pTarget[property] = value;
						}
					}
					else
					{
						Log.warning("Property \"" + property + "\" not found when applying style \"" + (pTarget is IStylable ? pTarget.styleName : "unknow") + "\" in \"" + pTarget + "\"");
					}
				}
			}
		}
		
		/**
		 * Récupérer la signature de style d'un élément stylisable.
		 * Cette signature s'exprime sous la forme d'un vecteur contenant le nom de styles de chaque parent, en partant du style de l'élément cible.
		 * @param	pTarget : L'élément dont on doit récupérer la signature
		 */
		public function getStyleSignature (pTarget:IStylable):Vector.<String>
		{
			// Le nom de classe de l'élément parent
			var parentClassName:String;
			
			// La liste des styles des parents
			var parentsStylesList:Vector.<String> = new Vector.<String>;
			
			// On commence par notre éléménet
			var parent:IStylable = pTarget;
			
			// Tant qu'on n'est pas sur le stage
			while (parent != null)
			{
				// Récupérer le nom de classe du parent
				parentClassName = getQualifiedClassName(parent);
				
				// Virer les package
				parentClassName = parentClassName.substring(parentClassName.lastIndexOf("::") + 2, parentClassName.length);
				
				// On ajoute le parent à notre liste de parents
				if (parent.styleName != null && parent.styleName != "")
					parentsStylesList.push(parentClassName + "." + parent.styleName);
				else
					parentsStylesList.push(parentClassName);
				
				// On remonte d'un niveau
				parent = (parent.parentStylable as IStylable);
			}
			
			// On retourne la liste à l'envers
			return parentsStylesList.reverse();
		}
		
		/**
		 * Signaler que les données de style ont changées
		 */
		public function invalidateStyleData ():void
		{
			// Dispatcher le changement de style
			_onStyleChanged.dispatch();
		}
		
		/**
		 * Définir un style (écrasera le type existant du même nom
		 * @param	pStyleName : Le nom du style (séparer les entitiées par des espaces)
		 * @param	pStyleData : Les données du style
		 */
		public function setStyle (pStyleName:String, pStyleData:Object):void
		{
			// Si on n'a pas d'objet style, on en créé un
			if (_styleData == null)
				_styleData = {};
			
			// Définir le style
			_styleData[pStyleName] = pStyleData;
			
			// Reparser les données
			parseStyleData();
		}
		
		/**
		 * Récupérer un style par le nom.
		 * @param	pStyleName : Le nom du style (séparer les entitiées par des espaces)
		 */
		public function getStyle (pStyleName:String):Object
		{
			if (pStyleName in _styleData)
				return _styleData[pStyleName];
			else
				return null;
		}
		
		/**
		 * Supprimer une délcaration de style
		 * @param	pStyleName : Le nom du style (séparer les entitiées par des espaces)
		 */
		public function deleteStyle (pStyleName:String):void
		{
			// Si le style existe
			if (pStyleName in _styleData)
			{
				// Supprimer le style
				delete _styleData[pStyleName];
				
				// Reparser les données
				parseStyleData();
			}
		}
		
		/**
		 * Ajouter un objet style
		 */
		public function addStyleData (pStyleData:IStyleData):void
		{
			// Parcourir les déclarations de ces données de style
			for (var i:String in pStyleData.styleData)
			{
				// Ajouter chaque déclaration
				_styleData[i] = pStyleData.styleData[i];
			}
			
			// Actualiser les données
			parseStyleData();
		}
		
		/**
		 * Supprimer un objet style
		 */
		public function removeStyleData (pStyleData:IStyleData):void
		{
			// Parcourir les déclarations de ces données de style
			for (var i:String in pStyleData.styleData)
			{
				// Supprimer chaque déclaration
				delete _styleData[i];
			}
			
			// Actualiser les données
			parseStyleData();
		}
		
		/**
		 * Détruire cet élément
		 */
		public function dispose ():void
		{
			_styleData = null;
			_selectors = null;
			
			_onStyleChanged.removeAll();
			_onStyleChanged = null;
			
			_onDisposed.dispatch();
			_onDisposed.removeAll();
			_onDisposed = null;
			
			// TODO : vérifier si tout est bien disposé dans StyleCentral
		}
	}
}