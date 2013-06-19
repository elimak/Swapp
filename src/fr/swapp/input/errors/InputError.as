package fr.swapp.input.errors 
{
	import fr.swapp.core.errors.SwappError;
	
	/**
	 * Internal swapp touch error
	 * @author ZoulouX
	 */
	public class InputError extends SwappError
	{
		/**
		 * Throw runtime error for input framework
		 * @param	pMethod : Class and method name firing the error like : "MyClass.myMethod"
		 * @param	pMessage : Associated message to the error
		 * @param	pId : Error ID (optionnal)
		 */
		public function InputError (pMethod:String, pMessage:String, pId:uint = 0)
		{
			// Relayer
			super(pMethod, pMethod, pId);
		}
	}
}