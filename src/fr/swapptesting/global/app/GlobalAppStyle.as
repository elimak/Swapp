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
							left: 7,
							width: 100
						},
						rightButton: {
							top: 6,
							right: 7,
							width: 100
						},
						
						// Le titre
						title: {
							// Placer
							left: 170,
							right: 170,
							top: 7,
							bottom: 2,
							
							// La type
							align: "center",
							color: 0x000000,
							fontSize: 20,
							font: "Arial",
							bold: true
							//fontRender: [true, true]
						}
					},
					
					// Le contenu
					content: {
						place: [44, 0, 0, 0]
					}
				},
				
				// Les boutons de la barre de titre
				"# SButton" : {
					height: 30,
					backgroundGraphic: {
						radius: [4],
						background: [0xFF7777, 1, SBackgroundType.VERTICAL_GRADIENT, 0XFF3333, 1]
					}
				},
				
				// Les boutons de la barre de titre
				"# .normal" : {
					backgroundGraphic: {
						background: [0xFF7777, 1, SBackgroundType.VERTICAL_GRADIENT, 0XFF3333, 1]
					}
				},
				
				// Les boutons de la barre de titre
				"# .pressed" : {
					backgroundGraphic: {
						background: [0XFF2B2B, 1, SBackgroundType.VERTICAL_GRADIENT, 0XCC0000, 1]
					}
				},
				
				// Les boutons de la barre de titre
				"# .disabled" : {
					backgroundGraphic: {
						background: [0XC3C3C3, 1, SBackgroundType.VERTICAL_GRADIENT, 0X8A8A8A, 1]
					}
				}
			});
		}
	}
}