# Swapp Roadmap

---

/**
 * 
 * VERIFICATIONS :
 * - Vérification de tous les disposes (dans une liste, l'ordre de dispose entre les enfants et les parents, dispose sur les textBase, etc...)
 * - Vérifier le fonctionnement du cache as bitmap sur les textField dans textBase
 * - Fonctionnement chelou sur iPad 1 des Label en cacheAsBitmap
 * 
 */

/**
 * 
 * Gesture Touch :
 * - Réparer l'effet de tremblement sur la demo d'interception de delegate dans ResizableComponentTest. Peut-être faut-il render le parent ou un truc du genre.
 * - Dispatcher les TAP et les DOUBLE TAP
 * 
 * Gesture Touch v2 :
 * - Dispatcher les TRANSFORM
 * - Dispatcher les TRANSFORM MATRIX
 * 
 */

/**
 * 
 * AVirtualList : 
 * - Refactorer (changements de packages + nouveau invalidate)
 * - Revérifier le l'ordre des appels (surtout vérifier le fonctionnement de render au sein de la liste et de son container)
 * - Réparer le "elementResizedHandler" qui fait des boucles infinies
 * 
 * AVirtualList v2 :
 * - Tester MouseWheel et implémenter touches haut bas gauche droite entrer sur les listes pour Android et PC
 * - Développer la scrollBar, proposer la classe non skinnée et la possibilité de skinner via les styles
 * 
 */

/**
 * 
 * Views / Navigation :
 * - Refactorer
 * - Style dans les vues
 * - Styles par défaut sur les vues, les popups et les navs
 * - Le resizableComponenent des vues doit pouvoir remonter à sa vue / popup attachée
 * - Visible qui dispatch un signal en cascade (sur les vues et sur les ResizableComponent)
 * - Trouver un moyen de retrouver une vue par son nom via le bootstrap
 * 
 */

/**
 * 
 * AdvancedBitmap :
 * - Dégradés (horizontaux, verticaux, matrix / Méthode d'ajout de couleur au dégradé (avec couleur, alpha, position) / Méthode de suppression de couleur de dégradé.
 * - Ecraser le scale9 sur le composant est plus petit que le bitmap source (jouer avec la propriété allowOverflow)
 * - Tester les scale9 un peu chelou (le slice de droite n'a pas l'air d'être callé au pixel)
 * 
 * AdvancedBitmap v2 :
 * - Faire un rendu bitmap des fonds vecto en RenderMode BITMAP (drawWithQuality d'un shape non addChild dans le _bitmap, actualiser à chaque draw)
 *
 */

/**
 * 
 * StyleCentral : 
 * - Faire une CSS par défaut (s'inspirer de Twitter Bootstrap)
 * http://twitter.github.com/bootstrap/components.html -> SWC
 * 
 * StyleCentral v2 :
 * - Tween auto entre les styles (une propriété de style qui s'appel 'tweens' et qui contiendrait en clé les variables a tweener et en valeur les propriété tweenmax (dont la durée et d'autres truc comme stop etc)
 * - Valeurs par défaut sur les styles (voir si c'est utile)
 * - Opérateur ">" sur les signatures de style
 * - Détéction des elements "de type" dans les signatures (par ex : "Popup TitleBar" en selecteur pour séléctionner toutes les TitleBar de toutes les popups)
 * 
 */


---------------- EN VRAC ----------------

Overrider "visible" dans ResizableComponent, dispatcher un signal au changement. Préremplir des méthodes protégé "activated" "deactivated".
Implémenter visible qui appel onActivated etc, aussi sur les vues. Système en cascade.
Ajouter la grille de vidéos de zapiks iPad dans babos (a refactorer)
Passer IView en stylable
Proposer un moyen de retrouver une vue par rapport à un ResizableComponent
Proposer un moyen de trouver une vue ou son viewController par son nom via Bootstrap
Proposer une API qui permet de cibler la Vue / Popup / Resizable / parente la plus proche
Refactorer la navigation et les popups


-------------- SCAFFOLDING --------------

- Demande du nom du projet et domaine inverse
- Création d'un projet mobile flashdevelop avec fichier AirAssistant remplis
- Création et checkout du dosser fr.babos dans src/
- Création de Structure de base / DocumentClass / Bundle / Style / Actions / AppViewController / AppView -> en mxml/as
- Créer un trio MVC HomeView / HomeViewController / HomeModel + action


------------- DOCUMENTATION--------------

-> Compiler la doc via ASDOC et l'up sur github

Plan :
1. Introduction
2. Pourquoi
	a. Constat
	b. Objectif
	c. Services Rendus
3. La structure
	a. Principes (MVC etc)
	b. Diagrammes (éléments structurels du framwork et interaction entre ces éléments)
	c. Le bundle
	d. Le trio MVC du framework
	e. Le bootstrap et les actions
	f. L'injection de dépendances
4. Les données
	a. Principes
	b. Diagrammes
	c. Model / Services
	d. Remote / Parser
	e. DataCollection / Items
5. L'affichage
	a. Principes
	b. Diagrammes (différents elements et interactions)
	c. Package Display (MasterMovieClip etc)
	d. Les composants
		- ResizableComponent / StageWrapper
		- AdvancedBitmap
		- Text
		- Button
		- List
		- Medias
		- Misc
	e. Styles
	f. Layouts
	g. Navigation (stacks / popups / animations / etc)
6. Utilitaires
	a. utils.*
	b. GestureEmulator
	c. BitmapCache
	d. Localisation
	e. ObjectPool
	f. Log
	g. Audio
6. Application d'exemple (client twitter ?)