"""
This is a workaround to get type hints on factory_boy factories

Usage:

# models.py

class MyModel:
    pass

# factories.py

class MyModelFactory(factory.Factory, metaclass=BaseMetaFactory[MyModel]):
    class Meta:
        model = MyModel

https://github.com/FactoryBoy/factory_boy/issues/468#issuecomment-1151633557
"""

from typing import Generic, TypeVar

import factory

T = TypeVar("T")


class BaseMetaFactory(Generic[T], factory.base.FactoryMetaClass):
    def __call__(cls, *args, **kwargs) -> T:
        return super().__call__(*args, **kwargs)
