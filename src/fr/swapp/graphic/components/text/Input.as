package fr.swapp.graphic.components.text
{
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import fr.swapp.core.log.Log;
	import fr.swapp.graphic.errors.GraphicalError;
	
	/**
	 * @author ZoulouX
	 */
	public class Input extends Label
	{
		/**
		 * Le texte à afficher par défaut
		 */
		protected var _placeHolderText						:String				= "";
		
		/**
		 * La couleur du texte par défaut (-1 pour aucun changement de couleur)
		 */
		protected var _placeHolderColor						:int				= -1;
		
		/**
		 * Relayer les evènements softKeyboard sur le stage
		 */
		protected var _dispatchSoftKeyboardEvents			:Boolean			= true;
		
		/**
		 * Si c'est un mot de passe
		 */
		protected var _password								:Boolean			= false;
		
		/**
		 * Si on est en focus
		 */
		protected var _inFocus								:Boolean			= false;
		
		
		/**
		 * Le texte à afficher par défaut
		 */
		public function get placeHolderText ():String { return _placeHolderText; }
		public function set placeHolderText (value:String):void
		{
			// Enregistrer le texte
			_placeHolderText = value;
		}
		
		/**
		 * La couleur du texte par défaut
		 */
		public function get placeHolderColor ():int { return _placeHolderColor; }
		public function set placeHolderColor (value:int):void
		{
			// Enregistrer la couleur
			_placeHolderColor = value;
		}
		
		/**
		 * La valeur du champs texte
		 */
		override public function get value ():String
		{
			if (_textField.text == _placeHolderText)
			{
				return "";
			}
			else
			{
				return _textField.text;
			}
		}
		override public function set value (value:String):void 
		{
			// Enregistrer le texte
			_textField.text = value;
			
			// Actualiser la taille
			resized();
		}
		
		/**
		 * Relayer les evènements softKeyboard sur le stage
		 */
		public function get dispatchSoftKeyboardEvents ():Boolean { return _dispatchSoftKeyboardEvents; }
		public function set dispatchSoftKeyboardEvents (value:Boolean):void 
		{
			_dispatchSoftKeyboardEvents = value;
		}
		
		/**
		 * Si c'est un mot de passe
		 */
		public function get password ():Boolean { return _password; }		
		public function set password (value:Boolean):void
		{
			// Si on doit afficher en tant que password
			_password = value;
			
			// Appliquer sur le textField
			_textField.displayAsPassword = _password;
		}
		
		/**
		 * Taille automatique du composant selon le contenu
		 */
		override public function get autoSize ():Boolean { return _autoSize; }
		override public function set autoSize (value:Boolean):void
		{
			if (value)
				Log.warning("Can't use autoSize on Input.");
		}
		
		/**
		 * Si le texte est séléctionnable
		 */
		override public function get selectable ():Boolean { return _textField.selectable; }
		override public function set selectable (value:Boolean):void 
		{
			if (!value)
				Log.warning("Input is always selectable");
		}
		
		
		/**
		 * Le constructeur
		 */
		public function Input (pMultiline:Boolean = false, pPlaceHolderText:String = "", pPlaceHolderColor:int = -1)
		{
			// Relayer
			super(false, pMultiline);
			
			// Le placeholder
			placeHolder(pPlaceHolderText, pPlaceHolderColor);
		}
		
		
		/**
		 * Activer le cache as bitmap
		 */
		override protected function enableFlatText ():void
		{
			// Sur les inputs, pas de matrice pour le textField (comportement chelou sur iOS)
			
			// Activer le stockage bitmap
			_textField.cacheAsBitmap = true;
		}
		
		/**
		 * Construire le textField
		 */
		override protected function buildTextField ():void
		{
			// Relayer
			super.buildTextField();
			
			// Réactiver l'interactivité
			_textField.selectable = true;
			_textField.mouseEnabled = true;
			
			// TextField en mode input
			_textField.type = TextFieldType.INPUT;
			
			// Ecouter le clavier virtuel
			//_textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, softKeyboardEventHandler);
			//_textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, softKeyboardEventHandler);
			//_textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, softKeyboardEventHandler);
			
			// Ecouter le focus
			_textField.addEventListener(FocusEvent.FOCUS_IN, focusHandler);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, focusHandler);
		}
		
		/**
		 * Initialisation
		 */
		override public function init ():void
		{
			// Activer le stockage bitmap
			_textField.cacheAsBitmap = true;
		}
		
		/**
		 * Changement de focus
		 */
		protected function focusHandler (event:FocusEvent):void 
		{
			// Si on est en focus
			if (event.type == FocusEvent.FOCUS_IN)
			{
				_inFocus = true;
			}
			else (event.type == FocusEvent.FOCUS_OUT)
			{
				_inFocus = false;
			}
			
			// Si on a un placeholder
			if (_placeHolderText != "")
			{
				// Si on active le focus et que le placeholder est affiché
				if (event.type == FocusEvent.FOCUS_IN && _textField.text == _placeHolderText)
				{
					// On vire le placeholder
					_textField.text = "";
					
					// Invalider
					invalidateTextFormat();
				}
				
				// Si on désactive le focus et que le champs est vide
				else if (event.type == FocusEvent.FOCUS_OUT && _textField.text == "")
				{
					// on affiche le placeholder
					_textField.text = _placeHolderText;
					
					// Invalider
					invalidateTextFormat();
				}
			}
		}
		
		/**
		 * Définir le texte affiché (pas d'HTML)
		 * @param	pValue : Le texte à afficher
		 */
		override public function text (pValue:String):TextBase
		{
			// Si on a un placeholder et qu'on n'a pas de texte
			if (pValue == "" && _placeHolderText != "")
			{
				// On affiche le placeholder
				super.text(_placeHolderText);
			}
			else
			{
				// Sinon on relais
				super.text(pValue);
			}
			
			// Invalider
			invalidateTextFormat();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Actualiser la couleur du texte selon le placeholder
		 */
		protected function updatePlaceHolderColor ():void
		{
			// Si on a un placeholder et une couleur de placeholder
			if (_placeHolderColor != -1 && _placeHolderText != "" && _textField.text == _placeHolderText)
			{
				// On applique la couleur du placeholder
				_textField.textColor = _placeHolderColor;
				_textField.displayAsPassword = false;
			}
			else
			{
				// Appliquer la couleur du texte
				if (_textFormat.color != null)
					_textField.textColor = parseFloat(_textFormat.color.toString());
				
				_textField.displayAsPassword = _password;
			}
		}
		
		/**
		 * Texte par défaut
		 * @param	pPlaceHolderText : Le texte par défaut
		 * @param	pPlaceHolderColor : La couleur du texte par défaut (-1 pour inchangée)
		 */
		public function placeHolder (pPlaceHolderText:String, pPlaceHolderColor:int = -1):Input
		{
			// Enregistrer
			_placeHolderText = pPlaceHolderText;
			_placeHolderColor = pPlaceHolderColor;
			
			// Si on n'a pas de texte on appliquer le placeHolder
			if (_textField.text == "")
				_textField.text = _placeHolderText;
			
			// Invalider
			invalidateTextFormat();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Actualiser le format
		 */
		override protected function updateTextFormat ():void
		{
			// Relayer
			super.updateTextFormat();
			
			// Actualiser la couleur du placeholder
			updatePlaceHolderColor();
		}
		
		/**
		 * Besoin d'être replacé
		 */
		override protected function needReplace ():void
		{
			// Retour au flux
			updateFlow();
			
			// Appliquer la taille du textField au composant
			_textField.width = _localWidth;
			_textField.height = _localHeight;
		}
		
		/**
		 * Le clavier virtuel change d'état
		 */
		/*
		protected function softKeyboardEventHandler (event:SoftKeyboardEvent):void
		{
			// Si on a un stage
			if (stage != null && _dispatchSoftKeyboardEvents)
			{
				// On relais cet event sur le stage
				stage.dispatchEvent(event);
			}
		}
		*/
		
		/**
		 * Destruction
		 */
		override public function dispose():void 
		{
			// Relayer
			super.dispose();
			
			// Ne plus écouters
			//_textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, softKeyboardEventHandler);
			//_textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, softKeyboardEventHandler);
			//_textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, softKeyboardEventHandler);
			
			_textField.removeEventListener(FocusEvent.FOCUS_IN, focusHandler);
			_textField.removeEventListener(FocusEvent.FOCUS_OUT, focusHandler);
		}
	}
}