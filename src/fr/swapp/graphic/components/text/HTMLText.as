package fr.swapp.graphic.components.text
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextRun;
	import fr.swapp.graphic.components.controls.TouchCallout;
	import fr.swapp.utils.ObjectUtils;
	import fr.swapp.utils.TimerUtils;
	import org.osflash.signals.Signal;
	/**
	 * @author ZoulouX
	 */
	public class HTMLText extends TextBase
	{
		/**
		 * Lorsqu'un lien est cliqué
		 */
		protected var _onLinkTapped							:Signal						= new Signal(String);
		
		/**
		 * Surcharger les liens avec des zones pour le tactile
		 */
		protected var _touchFriendlyLinks					:Boolean 					= true;
		
		/**
		 * Couleur du lien au tap
		 */
		protected var _linkTapColor							:uint						= 0x888888;
		
		/**
		 * L'alpha du lien au tap
		 */
		protected var _linkTapAlpha							:Number						= .4;
		
		/**
		 * Le border radius des liens au tap
		 */
		protected var _linkTapBorderRadius					:int						= 5;
		
		/**
		 * Le padding horizontal des liens
		 */
		protected var _horizontalLinkTapPadding				:int						= 2;
		
		/**
		 * Le padding vertical des liens
		 */
		protected var _verticalLinkTapPadding				:int						= 0;
		
		/**
		 * La durée d'affichage du lien
		 */
		protected var _linkTapDuration						:Number						= .5;
		
		/**
		 * Si la disparition du lien doit se faire en animation
		 */
		protected var _linkTapAnimated						:Boolean					= true;
		
		/**
		 * Les callouts
		 */
		protected var _callouts								:Vector.<TouchCallout>	= new Vector.<TouchCallout>;
		
		
		/**
		 * Le style associé à ce texte HTML
		 */
		public function get styleSheet ():StyleSheet { return _textField.styleSheet; }
		public function set styleSheet (value:StyleSheet):void
		{
			_textField.styleSheet = value;
			
			// Invalider
			invalidate();
		}
		
		/**
		 * Lorsqu'un lien est cliqué
		 */
		public function get onLinkTapped ():Signal { return _onLinkTapped; }
		public function set onLinkTapped (value:Signal):void
		{
			_onLinkTapped = value;
		}
		
		/**
		 * Surcharger les liens avec des zones pour le tactile
		 */
		public function get touchFriendlyLinks ():Boolean { return _touchFriendlyLinks; }
		public function set touchFriendlyLinks (value:Boolean):void
		{
			// Si c'est différent
			if (value != _touchFriendlyLinks)
			{
				// Enregistrer
				_touchFriendlyLinks = value;
				
				// Invalider
				invalidate();
			}
		}
		
		/**
		 * Couleur du lien au tap
		 */
		public function get linkTapColor ():uint { return _linkTapColor; }
		public function set linkTapColor (value:uint):void
		{
			// Si c'est différent
			if (value != _linkTapColor)
			{
				// Enregistrer
				_linkTapColor = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		/**
		 * L'alpha du lien au tap
		 */
		public function get linkTapAlpha ():Number { return _linkTapAlpha; }
		public function set linkTapAlpha (value:Number):void
		{
			// Si c'est différent
			if (value != _linkTapAlpha)
			{
				// Enregistrer
				_linkTapAlpha = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		/**
		 * Le border radius des liens au tap
		 */
		public function get linkTapBorderRadius ():int { return _linkTapBorderRadius; }
		public function set linkTapBorderRadius (value:int):void
		{
			// Si c'est différent
			if (value != _linkTapBorderRadius)
			{
				// Enregistrer
				_linkTapBorderRadius = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		/**
		 * Le padding horizontal des liens
		 */
		public function get horizontalLinkTapPadding ():int { return _horizontalLinkTapPadding; }
		public function set horizontalLinkTapPadding (value:int):void
		{
			// Si c'est différent
			if (value != _horizontalLinkTapPadding)
			{
				// Enregistrer
				_horizontalLinkTapPadding = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		/**
		 * Le padding vertical des liens
		 */
		public function get verticalLinkTapPadding ():int { return _verticalLinkTapPadding; }
		public function set verticalLinkTapPadding (value:int):void
		{
			// Si c'est différent
			if (value != _verticalLinkTapPadding)
			{
				// Enregistrer
				_verticalLinkTapPadding = value;
				
				// Invalider
				invalidate();
			}
		}
		
		/**
		 * La durée d'affichage du lien
		 */
		public function get linkTapDuration ():Number { return _linkTapDuration; }
		public function set linkTapDuration (value:Number):void
		{
			// Si c'est différent
			if (value != _linkTapDuration)
			{
				// Enregistrer
				_linkTapDuration = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		/**
		 * Si la disparition du lien doit se faire en animation
		 */
		public function get linkTapAnimated ():Boolean { return _linkTapAnimated; }
		public function set linkTapAnimated (value:Boolean):void
		{
			// Si c'est différent
			if (value != _linkTapAnimated)
			{
				// Enregistrer
				_linkTapAnimated = value;
				
				// Appliquer sur les callOuts
				updateCallouts();
			}
		}
		
		
		/**
		 * Le constructeur
		 */
		public function HTMLText (pAutoSize:Boolean = true, pMultiLine:Boolean = true, pTouchFriendlyLinks:Boolean = true, pValue:String = "")
		{
			autoSize = pAutoSize;
			multiline = pMultiLine;
			touchFriendlyLinks = pTouchFriendlyLinks;
			
			if (value != null && value != "")
				html(value);
		}
		
		/**
		 * Supprimer tous les callouts
		 */
		protected function deleteAllCallouts ():void
		{
			// Supprimer tous les callouts
			for each (var callout:TouchCallout in _callouts)
			{
				callout.onTapped.remove(calloutTappedHandler);
				removeChild(callout);
			}
		}
		
		/**
		 * Faire le rendu HTML
		 */
		public function renderHTML ():void
		{
			// Tout supprimer
			deleteAllCallouts();
			
			// Remettre le tableau des liens à 0
			_callouts = new Vector.<TouchCallout>;
			
			// Si on doit afficher les liens de manière super sympa
			if (_touchFriendlyLinks)
			{
				// Récupérer tous les textFormats de ce texte
				var runs			:Array 			= _textField.getTextRuns();
				var i				:int 			= runs.length;
				
				// Les variables de la boucle
				var run				:TextRun;
				var url				:String;
				var line1			:int;
				var line2			:int;
				var totalLines		:int;
				var j				:int;
				var calloutID		:int			= 0;
				
				// ATTENTION : Il faut récupérer les position d'un caractère avant de récupérer getLineIndexOfChar !
				// getCharBoundaries permet de fixer un bug sur getLineIndexOfChar.
				textField.getCharBoundaries(0);
				
				// Les parcourir
				while (i -- > 0)
				{
					// Cibler le run
					run = runs[i];
					
					// On a un lien
					url = run.textFormat.url;
					
					// Si on tombe sur un lien
					if (url.length > 0)
					{
						// Compter le nombre de lignes
						line1 = textField.getLineIndexOfChar(run.beginIndex);
						line2 = textField.getLineIndexOfChar(run.endIndex);
						
						// Compter le nombre de lignes sur lequel le lien va s'étaler
						totalLines = (line2 - line1) + 1;
						
						// Si on n'a qu'une ligne
						if (totalLines == 1)
						{
							addCallout(run.beginIndex, run.endIndex - 1, calloutID, url);
						}
						
						// Si on a plusieur lignes
						else
						{
							// Parcourir les lignes
							j = totalLines;
							while (-- j >= 0)
							{
								// Première ligne
								if (j == 0)
								{
									addCallout(
										run.beginIndex,
										textField.getLineOffset(line1) + textField.getLineLength(line1) - 1,
										calloutID,
										url
									);
								}
								
								// Dernière ligne
								else if (j == totalLines - 1)
								{
									addCallout(
										textField.getLineOffset(line2),
										run.endIndex - 1,
										calloutID,
										url
									);
								}
								
								// Lignes intermédiaires
								else
								{
									addCallout(
										textField.getLineOffset(line1 + j),
										textField.getLineOffset(line1 + j) + textField.getLineLength(line1 + j) - 1,
										calloutID,
										url
									);
								}
							}
						}
						
						// Passer au callout suivant
						calloutID ++;
					}
				}
			}			
		}
		
		/**
		 * Ajouter un callout sur un lien
		 * @param	pFirstIndex : L'index du premier caractère
		 * @param	pLastIndex : L'index du dernier caractère
		 * @param	pID : L'ID du callout (plusieurs callouts peuvent avoir le même ID)
		 * @param	pURL : Le lien du callout
		 */
		protected function addCallout (pFirstIndex:int, pLastIndex:int, pID:int, pURL:String):void
		{
			// Attendre une frame...... (sinon getCharBoundaries retourne null)
			TimerUtils.wait(this, 1, true, function ():void
			{
				// Récupérer la position des 2 caractères a entourrer
				var firstRect		:Rectangle	= textField.getCharBoundaries(pFirstIndex);
				var lastRect		:Rectangle	= textField.getCharBoundaries(pLastIndex);
				
				// Si les rectangles sont valides
				if (firstRect != null && lastRect != null)
				{
					// Créer le callout
					var callout:TouchCallout = new TouchCallout(_linkTapColor, _linkTapAlpha, _linkTapBorderRadius, _linkTapDuration, _linkTapAnimated);
					
					// Le placer
					callout.rectPlace(
						firstRect.x - _horizontalLinkTapPadding,
						Math.min(firstRect.y, lastRect.y) - _verticalLinkTapPadding,
						(lastRect.x - firstRect.x) + lastRect.width + _horizontalLinkTapPadding * 2,
						Math.max(firstRect.height, lastRect.height) + _verticalLinkTapPadding * 2
					);
					
					// L'ajouter
					_callouts.push(callout);
					
					// Lui passer ses infos
					callout.data = {
						id: pID,
						url: pURL
					};
					
					// L'afficher
					callout.into(this);
					
					// Ecouter lorsqu'on clic sur le callout
					callout.onTapped.add(calloutTappedHandler);
				}
			});
		}
		
		/**
		 * Clic sur un callout
		 */
		protected function calloutTappedHandler (pCallout:TouchCallout):void
		{
			// Parcourir tous les callouts
			for each (var callout:TouchCallout in _callouts)
			{
				// Si un callout a le même ID
				if (pCallout.data.id == callout.data.id && callout != pCallout)
				{
					// On l'affiche
					callout.show();
				}
			}
			
			// Dispatcher
			_onLinkTapped.dispatch(pCallout.data.url);
		}
		
		/**
		 * Actualiser les callouts
		 */
		protected function updateCallouts ():void
		{
			// Supprimer tous les callouts
			for each (var callout:TouchCallout in _callouts)
			{
				callout.background(_linkTapColor, _linkTapAlpha);
				callout.radius(_linkTapBorderRadius);
				callout.animated = _linkTapAnimated;
				callout.duration = _linkTapDuration;
			}
		}
		
		/**
		 * Définir le style du texte
		 * @param	pStyle : La CSS
		 */
		public function style (pStyle:Object):HTMLText
		{
			// Si on a un style
			if (pStyle != null)
			{
				// Si notre style est un objet stylesheet
				if (pStyle is StyleSheet)
				{
					// On cast juste
					_textField.styleSheet = pStyle as StyleSheet;
				}
				
				// Si c'est du String ou de l'XML, on parse
				else if (pStyle is String)
				{
					_textField.styleSheet = new StyleSheet();
					_textField.styleSheet.parseCSS(pStyle as String);
				}
				else if (pStyle is XML)
				{
					_textField.styleSheet = new StyleSheet();
					_textField.styleSheet.parseCSS((pStyle as XML).toString());
				}
				else
				{
					_textField.styleSheet = ObjectUtils.extra(new StyleSheet(), pStyle) as StyleSheet;
				}
			}
			else
			{
				_textField.styleSheet = null;
			}
			
			// Invalider
			invalidate();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Paramètrer le rendu des liens
		 * @param	pEnabled : Si on active le liens tactiles
		 * @param	pColor : La couleur du callOut
		 * @param	pAlpha : L'alpha du callOut
		 * @param	pHorizontalPadding : Le padding horizontal du callOut
		 * @param	pVerticalPadding : Le padding vertical du callOut
		 * @param	pDuration : La durée d'affichage du lien
		 * @param	pAnimated : Si la disparition du lien doit se faire en animation
		 */
		public function touchLinks (pEnabled:Boolean, pColor:int = 0x888888, pAlpha:Number = .4, pHorizontalPadding:int = 4, pVerticalPadding:int = 2, pDuration:Number = .5, pAnimated:Boolean = true):HTMLText
		{
			// Enregistrer
			_touchFriendlyLinks = pEnabled;
			_linkTapColor = pColor;
			_linkTapAlpha = pAlpha;
			_horizontalLinkTapPadding = pHorizontalPadding;
			_verticalLinkTapPadding = pVerticalPadding;
			_linkTapDuration = pDuration;
			_linkTapAnimated = pAnimated;
			
			// Invalider
			invalidate();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Replacer
		 */
		override protected function needReplace ():void
		{
			// Relayer
			super.needReplace();
			
			// Actualiser le format du texte
			renderHTML();
			
		}
		
		/**
		 * Destruction
		 */
		override public function dispose ():void
		{
			_onLinkTapped.removeAll();
			_onLinkTapped = null;
			
			deleteAllCallouts();
			
			super.dispose();
		}
	}
}