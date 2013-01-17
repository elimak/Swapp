package fr.swapp.core.dependences 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author ZoulouX
	 */
	public interface IDependencesManager 
	{
		/**
		 * Récupérer les dépendences.
		 * Dictionnaire avec classe en clé et objet associatif des dépendances en valeur.
		 */
		function get dependences ():Dictionary;
		
		/**
		 * Récupérer les concrêtes.
		 * Dictionnaire avec classe en clé et concrête en valeur.
		 */
		function get concretes ():Dictionary;
		
		/**
		 * Ajouter une dépendance
		 * @param	pClass : La classe qui va recevoir des dépendances
		 * @param	pDependences : La liste des dépendances pour cette classe. En clé la propriété sur laquelle injecter, en valeur : La classe ou la concrête à injecter.
		 */
		function addDependences (pClass:Class, pDependences:Object = null):void;
		
		/**
		 * Récupérer les dépendances d'une classe
		 * @param	pClass : La classe
		 */
		function getDependences (pClass:Class):Object;
		
		/**
		 * Supprimer une dépendance
		 * @param	pClass : La classe qui ne va plus recevoir de dépendances
		 */
		function removeDependences (pClass:Class):void;
		
		/**
		 * Mapper une concrête (sera utilisée pour chaque demande de son type de classe)
		 * @param	pClass : La classe exacte sur laquelle sera utilisée la concrête
		 * @param	pConcrete : La concrête. Si une classe ou rien n'est passé, la classe sera instancée à la demande EN SINGLETON.
		 * @param	pCustomDependences : La liste (associative) des propriétés du host (en clé) qui vont accueillir les concrêtes (leur classe en valeur) instanciées et injectées. (si null, alors la liste des dépendances sera récupérée depuis la manager)
		 */
		function addConcrete (pClass:Class, pConcrete:* = null, pCustomDependences:Object = null):void;
		
		/**
		 * Mapper une concrête (sera utilisée pour chaque demande de son type de classe)
		 * @param	pClass : La classe associée à une concrête
		 */
		function getConcrete (pClass:Class):Object
		
		/**
		 * Supprimer une concrête
		 * @param	pClass : La classe de la concrête
		 */
		function removeConcrete (pClass:Class):void;
		
		/**
		 * Instancier une classe et y injecter les dépendances automatiquement
		 * @param	pClass : La classe de la concrête à créer
		 * @return : La concrête instanciée
		 */
		function instanciate (pClass:Class):Object;
		
		/**
		 * Récupérer les dépendances d'un objet. Cette fonction est récursive au niveau de l'héritage des classes.
		 * @param	pObject : L'objet
		 */
		function getDependencesForObject (pObject:*):Object;
		
		/**
		 * Injecter les dépendances automatiquement sur un objet
		 * @param	pObject : L'objet a injecter
		 * @param	pCustomDependences : La liste (associative) des propriétés du host (en clé) qui vont accueillir les concrêtes (leur classe en valeur) instanciées et injectées. (si null, alors la liste des dépendances sera récupérée depuis la manager)
		 * @param	pRecursivity : La récursivité (-1 pour infini)
		 * @param	pTempConcretes : Les concrêtes a utiliser sur l'injection au premier niveau.
		 */
		function inject (pObject:*, pCustomDependences:Object = null, pRecursivity:int = -1, pTempConcretes:Array = null):void;
	}
}