﻿package fr.swapp.core.roles 
{
	/**
	 * Cet élément peut être effacé de la mémoire.
	 * Pour cela il suffit d'implémenter la méthode dispose, appelable depuis l'exérieur.
	 * La méthode dispose doit alors tuer toutes les références, disposer les éléments disposables, et aussi ne plus écouter les évènements.
	 * @author ZoulouX
	 */
	public interface IDisposable 
	{
		/**
		 * If element is disposed
		 */
		function get disposed ():Boolean;
		
		/**
		 * Effacer cet élément de la mémoire
		 */
		function dispose ():void
	}	
}