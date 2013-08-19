package fr.swapptesting.global.app
{
	import fr.swapp.core.data.locale.Locale;
	import fr.swapp.graphic.base.SComponent;
	import fr.swapp.graphic.base.SGraphic;
	import fr.swapp.graphic.base.SView;
	import fr.swapp.graphic.containers.SContainer;
	import fr.swapp.graphic.controls.SButton;
	import fr.swapp.graphic.text.SLabel;
	
	/**
	 * @author ZoulouX
	 */
	public class GlobalAppView extends SView
	{
		public var $TitleBarLeftButton:SButton;
		public var $TitleBarRightButton:SButton;
		
		/**
		 * Constructor
		 */
		public function GlobalAppView () { }
		
		/**
		 * Construct interface
		 */
		override protected function buildInterface ():void
		{
			// Définir les composants
			setupComponents({
				titleBar: {
					leftButton	: new SButton(buttonTappedHandler),
					rightButton	: new SButton(buttonTappedHandler),
					title		: new SLabel(false, false, Locale.getText("home.greetings", {
						user: "ZoulouX"
					}))
				},
				content: {
					type: SContainer
				}
			});
			
			// Définir le style
			setStyleData(GlobalAppStyle);
		}
		
		protected function buttonTappedHandler (pTarget:SButton):void
		{
			trace("TAP", pTarget, pTarget == $TitleBarLeftButton, pTarget == $TitleBarRightButton);
			
			
			// Faudrait aussi qu'on puisse remonter facilement à un titleBar parent rapidement
			// Ou alors, faudrait avoir un objet de configuration et le navigationStack parent, intègre au moment de change sur le bootstrap
			
			// Faire les animations dans les styles
			// Faire la classe date à la momentum.js
			// Tester les mouseEnable false avec le system input (j'ai l'impression que ça passe quand même)
			
			// Coder TitleBar
			// Coder NavigationStack
			// Coder ViewStack
			// Coder Container (avec scroll pan pinch zoom) en généralisation IScrollable
			// Coder / tester la webview ainsi que le stageVideo
		}
	}
}