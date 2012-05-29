package fr.swapp.graphic.components.text 
{
	import flash.events.Event;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextInteractionMode;
	import fr.swapp.utils.ObjectUtils;
	
	/**
	 * @author ZoulouX
	 */
	public class Label extends TextBase
	{
		/**
		 * Le formatText
		 */
		protected var _textFormat						:TextFormat;
		
		/**
		 * Si le textFormat est invalidé
		 */
		protected var _textFormatInvalidated			:Boolean;
		
		
		/**
		 * Le textFormat du textField
		 */
		public function get textFormat ():TextFormat { return _textFormat; }
		public function set textFormat (value:TextFormat):void
		{
			// Si le textFormat n'est pas null
			if (value != null)
			{
				// Enregistrer
				_textFormat = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		
		/**
		 * La font
		 */
		public function get font ():String { return _textFormat.font; }
		public function set font (value:String):void
		{
			// Si c'est différent
			if (value != _textFormat.font)
			{
				// Enregistrer
				_textFormat.font = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * La taille de la typo
		 */
		public function get fontSize ():Object { return _textFormat.size; }
		public function set fontSize (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.size)
			{
				// Enregistrer
				_textFormat.size = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * La couleur du texte
		 */
		public function get color ():Object { return _textFormat.color; }
		public function set color (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.color)
			{
				// Enregistrer
				_textFormat.color = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Alignement du texte (voir TextFormatAlign)
		 */
		public function get align ():String { return _textFormat.align; }
		public function set align (value:String):void
		{
			// Si c'est différent
			if (value != _textFormat.align)
			{
				// Enregistrer
				_textFormat.align = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Si le texte est en gras
		 */
		public function get bold ():Object { return _textFormat.bold; }
		public function set bold (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.bold)
			{
				// Enregistrer
				_textFormat.bold = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Si le texte est en italique
		 */
		public function get italic ():Object { return _textFormat.italic; }
		public function set italic (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.italic)
			{
				// Enregistrer
				_textFormat.italic = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Si le texte est en italique
		 */
		public function get underline ():Object { return _textFormat.underline; }
		public function set underline (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.underline)
			{
				// Enregistrer
				_textFormat.underline = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Espace vertical entre les lignes
		 */
		public function get leading ():Object { return _textFormat.leading; }
		public function set leading (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.leading)
			{
				// Enregistrer
				_textFormat.leading = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * L'indentation du texte
		 */
		public function get indent ():Object { return _textFormat.indent; }
		public function set indent (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.indent)
			{
				// Enregistrer
				_textFormat.indent = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		/**
		 * Espace entre les lettres (peut être à virgule)
		 */
		public function get letterSpacing ():Object { return _textFormat.letterSpacing; }
		public function set letterSpacing (value:Object):void
		{
			// Si c'est différent
			if (value != _textFormat.letterSpacing)
			{
				// Enregistrer
				_textFormat.letterSpacing = value;
				
				// Invalider le format
				invalidateTextFormat();
			}
		}
		
		
		/**
		 * Le label à afficher
		 */
		public function Label (pAutoSize:Boolean = true, pMultiLine:Boolean = false, pValue:String = "")
		{
			autoSize = pAutoSize;
			multiline = pMultiLine;
			
			if (pValue != null && pValue != "")
				text(pValue);
		}
		
		
		/**
		 * Construire le textField
		 */
		override protected function buildTextField ():void
		{
			// Relayer
			super.buildTextField();
			
			// Appliquer un textFormat
			resetFormat();
		}
		
		/**
		 * Actualiser le format
		 */
		protected function updateTextFormat ():void
		{
			// Actualiser l'autosize
			updateAutoSize();
			
			// Appliquer sur le textField
			_textField.defaultTextFormat = _textFormat;
			_textField.setTextFormat(_textFormat, -1, -1);
		}
		
		/**
		 * Remettre le format à 0
		 */
		public function resetFormat ():Label
		{
			// Créer un nouveau textFormat
			_textFormat = new TextFormat(
				"arial",
				14,
				0x000000
			);
			
			// Invalider le format texte
			invalidateTextFormat();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Le format du textField
		 * @param	pFormat : L'objet textFormat ou un objet dynamique
		 */
		public function format (pFormat:Object):Label
		{
			// Si on a un format
			if (pFormat != null)
			{
				// Si notre format est bien un textFormat
				if (pFormat is TextFormat)
				{
					// On cast juste
					_textFormat = pFormat as TextFormat;
				}
				else
				{
					// On extra
					_textFormat = ObjectUtils.extra(_textFormat, pFormat) as TextFormat;
				}
			}
			
			// Invalider le format texte
			invalidateTextFormat();
			
			// Méthode chaînable
			return this;
		}
		
		/**
		 * Invalider le format du texte
		 */
		public function invalidateTextFormat ():void
		{
			// Signaler que le format est maintenant invalidé
			_textFormatInvalidated = true;
			
			// Relayer l'invalidation
			invalidate();
		}
		
		/**
		 * Rendu du stage
		 */
		override protected function renderHandler ():void
		{
			// Si le style est invalide
			if (_styleInvalidated)
			{
				// On l'actualise
				updateStyle();
				
				// Le style est valide
				_styleInvalidated = false;
			}
			
			// Appliquer les modifications au textFormat
			if (_textFormatInvalidated)
			{
				// Actualiser le format du texte
				updateTextFormat();
				
				// Le textFormat est valide
				_textFormatInvalidated = false;
			}
			
			// Attention, ici le style est géré alors qu'il est géré aussi dans super.renderHandler
			// Mais il faut que le style soit valide avant de valider le textFormat
			// Donc pas de panique, la viariable _styleInvalidated interdira la revalidation dans super.renderHandler
			
			// Relayer
			super.renderHandler();
		}
	}
}