package fr.swapptesting.global.app
{
	import fr.swapp.graphic.base.SBackgroundType;
	import fr.swapp.graphic.base.SRenderMode;
	import fr.swapp.graphic.styles.StyleData;
	
	/**
	 * @author ZoulouX
	 */
	public class GlobalAppStyle extends StyleData
	{
		public function GlobalAppStyle () { }
		
		override public function init ():void
		{
			setData({
				"#" : {
					// Placer la vue
					place: [0, 0, 0, 0],
					
					// La barre de titre
					titleBar : {
						// Placer
						height: 44,
						place: [0, 0, NaN, 0],
						
						// Le fond
						backgroundGraphic: {
							background: [0xEEEEEE, 1, SBackgroundType.VERTICAL_GRADIENT, 0xCCCCCC, 1]
						},
						
						// Les boutons
						leftButton: {
							top: 6,
							left: 5,
							width: 100
						},
						rightButton: {
							top: 6,
							right: 5,
							width: 100
						},
						
						// Le titre
						title: {
							// Placer
							left: 40,
							right: 40,
							top: 5,
							
							// La type
							align: "center",
							color: 0x000000,
							fontSize: 15,
							font: "Arial",
							fontRender: [true, true]
						}
					},
					
					// Le contenu
					content: {
						place: [44, 0, 0, 0]
					}
				},
				
				// Les boutons de la barre de titre
				"# .button" : {
					background: [0X88C4FF, 1, SBackgroundType.VERTICAL_GRADIENT, 0X409FFF, 1],
					height: 30,
					radius: [4]
				}
			});
		}
	}
}