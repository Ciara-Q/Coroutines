function __CoroutineRepeat(_countFunction)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineRepeatClass();
    _new.__repeatsFunction = method(global.__coroutineStack[0], _countFunction);
    
    __COROUTINE_PUSH_TO_PARENT;
    __COROUTINE_PUSH_TO_STACK;
}

function __CoroutineRepeatClass() constructor
{
    __functionArray = [];
    __repeatsFunction = undefined;
    
    __index = 0;
    __complete = false;
    
    __repeats = 1;
    __repeatCount = 0;
    
    static Restart = function()
    {
        __index = 0;
        __complete = false;
        
        __repeats = 1;
        __repeatCount = 0;
        
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_struct(_function) && !is_method(_function)) _function.Restart();
            ++_i;
        }
    }
    
    static __Run = function()
    {
        if (__complete) return undefined;
        
        //If this is the first function+repeat then set up our repeat count from the function/constant
        if ((__index == 0) && (__repeatCount == 0))
        {
            __repeats = __repeatsFunction();
            
            //Early out
            if (__repeats <= 0)
            {
                __complete = true;
                return undefined;
            }
        }
        
        do
        {
            var _function = __functionArray[__index];
            __COROUTINE_TRY_EXECUTING_FUNCTION;
            
            //Move to the next function
            if (__index >= array_length(__functionArray))
            {
                //Increase our repeats count. If we've reached the end then call us complete!
                ++__repeatCount;
                if (__repeatCount >= __repeats)
                {
                    __complete = true;
                }
                else
                {
                    var _oldRepeats = __repeats;
                    var _oldRepeatCount = __repeatCount;
                    
                    Restart();
                    
                    __repeats = _oldRepeats;
                    __repeatCount = _oldRepeatCount;
                }
            }
        }
        until ((global.__coroutineEscapeState > 0)
           ||  global.__coroutineBreak
           ||  __complete
           ||  (get_timer() > global.__coroutineApproxEndTime));
        
        global.__coroutineBreak = false;
    }
    
    static __Add = function(_new)
    {
        array_push(__functionArray, _new);
    }
}