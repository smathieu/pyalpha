#!/usr/bin/python
"""
The timeout module defines two decorators: 
@timeout(<time in seconds>) and
@default_timeout

These decorators can be used to decorate functions,  
as illustrated by the doctests below.

>>> import time

Test timing-out:
>>> @timeout(timeout=2)
... def return_later():
...     time.sleep(3)
...     return 'later'
>>>
>>> return_later()
Traceback (most recent call last):
    ...
TimeoutException

Test not-timing-out:
>>> @timeout(timeout=2)
... def return_in_one_second():
...     time.sleep(1)
...     return 'in one second'
>>>
>>> return_in_one_second()
'in one second'

Test timing-out:
>>> @default_timeout
... def return_later():
...     time.sleep(6)
...     return 'later'
>>>
>>> return_later()
Traceback (most recent call last):
    ...
TimeoutException

Test not-timing-out:
>>> @default_timeout
... def return_right_away():
...     return 'right away'
>>>
>>> return_right_away()
'right away'

Without decorating:
>>> def return_later(arg):
...     time.sleep(4)
...     return 'later ' + arg
>>> return_later_or_timeout = call_with_timeout(return_later, 3)
>>> return_later_or_timeout('foo')
Traceback (most recent call last):
    ...
TimeoutException

>>> def return_later(arg):
...     time.sleep(4)
...     return 'later ' + arg
>>> call_with_timeout(return_later, 6)('foo')
'later foo'

>>> getstatusoutput("sleep 1 ; echo 'foo'", 5)
(0, 'foo')
>>> getstatusoutput("sleep 3 ; echo 'foo'", 2)
(-1, "The command 'sleep 3 ; echo 'foo'' timed-out after 2 seconds.")


"""

import sys, signal, commands

DEFAULT_TIMEOUT = 5

class TimeoutException(Exception):
    """A timeout has occurred."""
    pass

class call_with_timeout: 
    def __init__(self, function, timeout=DEFAULT_TIMEOUT): 
        self.timeout = timeout 
        self.function = function 

    def handler(self, signum, frame): 
        raise TimeoutException()

    def __call__(self, *args): 
        # get the old SIGALRM handler
        old = signal.signal(signal.SIGALRM, self.handler) 
        # set the alarm
        signal.alarm(self.timeout) 
        try: 
            result = self.function(*args)
        finally: 
            # restore existing SIGALRM handler
            signal.signal(signal.SIGALRM, old)
        signal.alarm(0)
        return result 

def timeout(timeout):
    """This decorator takes a timeout parameter in seconds."""
    def wrap_function(function):
        return call_with_timeout(function, timeout)
    return wrap_function

def default_timeout(function):
    """This simple decorator 'timesout' after DEFAULT_TIMEOUT seconds."""
    return call_with_timeout(function)

def getstatusoutput(command, timeout=DEFAULT_TIMEOUT):
    """This is a timeout wrapper aroung getstatusoutput."""
    _gso = call_with_timeout(commands.getstatusoutput, timeout)
    try:
        return _gso(command)
    except TimeoutException, e:
        return (-1, "The command '%s' timed-out after %i seconds." % (command, timeout))

def _test():
    import doctest
    doctest.testmod()

if __name__ == "__main__":
    _test()

