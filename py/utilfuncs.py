import random

def user_select(myList, *, message="Please select an item: "):
    """
    Allows user to select an item from a list
    """
    userInput = None
    while userInput not in myList:
        userInput = input(message)
    return userInput

def prob_decision(probability):
    """
    returns true or false based on the given probability. for example, if probability = 0.7 this will return true 70% of the time
    """
    return random.random() < probability