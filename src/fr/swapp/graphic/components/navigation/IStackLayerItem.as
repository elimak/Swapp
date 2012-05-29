package fr.swapp.graphic.components.containers.stacks 
{
	import fr.swapp.core.bootstrap.BootstrapAction;
	
	/**
	 * Une couche dans un container stack
	 * @author ZoulouX
	 */
	public interface IStackLayerItem 
	{
		/**
		 * L'action déclanchée à la séléction d'un index
		 */
		function get action ():BootstrapAction;
		
		/**
		 * Le type de destruction de cette couche
		 */
		function get destructionPolicy ():String;
	}
}