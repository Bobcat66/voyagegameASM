import random
import utilfuncs as util
import ast
class ship():
    def __init__(self):
        self.supplies = 300
        self.crew = 180
        self.cargo = 0
        self.cannons = 23
        self.health = 100
        self.funds = 300
        self.level = 1 #base maximums: 300 supplies, 10 cannon, 3000 cargo, 100 health
        self.updateMax()
    def updateMax(self):
        self.max_supplies = 250 + self.level*50
        self.max_crew = 165 + self.level*15
        self.max_cargo = 2500 + self.level*500
        self.max_cannons = 18 + self.level*5
        self.max_health = 70 + self.level*30

    def changeSupply(self, value):
        if self.supplies + value > 0:
            self.supplies += value
        else:
            self.supplies = 0

    def changeCrew(self, value):
        if self.crew + value > 0:
            self.crew += value
        else:
            self.crew = 0

    def changeCargo(self, value):
        if self.cargo + value > self.max_cargo:
            self.cargo = self.max_cargo
        elif self.cargo + value < 0:
            self.cargo = 0
        else:
            self.cargo += value

    def changeCondition(self, value):
        if self.health + value > 0:
            self.health += value
        else:
            self.health = 0

    def changeFunds(self, value):
        self.funds += value

    def changeCannons(self, value):
        if self.cannons + value > 0:
            self.cannons += value
        else:
            self.cannons = 0

class instance():
    def __init__(self):
        self.events = {
            1 : self.becalmed,
            2 : self.storm,
            3 : self.becalmed,
            4 : self.warship_attack,
            5 : self.merchant_ship,
            6 : self.merchant_ship
        }
        self.ship = ship()
        self.game_state = 1 #1 means the game is active, 2 means the game is over
        self.returnVoyage = False #whether or not the player is on the return voyage or not
        print("You are pirat caipetn")
        self.voyageCounter = 0
        while self.game_state == 1:
            if self.returnVoyage:
                print("You have done the pirart!")
                print("Now you must do the another pirtatcy!")
            else:
                print("Kapten Jacques Birdman, Thne priate capan!")
            self.supply()
            self.game()
            if self.game_state == 2:
                break
            self.returnVoyage = not self.returnVoyage
            self.voyageCounter += 1
            endgame_choice = util.user_select(["y","n"],message="Do you want to continue the game? [y/n]: ")
            if endgame_choice == "n":
                self.end_game()
            else:
                pass
            self.ship.funds += self.ship.cargo
            self.ship.cargo = 0
        print("GAME OVER")
        print("---------STATS---------")
        print(f"Voyages: {self.voyageCounter}")
        print(f"Current cash: {self.ship.funds}")
        print(f"Total score: {self.ship.funds + (self.voyageCounter*2000)}")

    def game(self):
        self.weeks_left = 18
        self.current_week = 0
        self.resupply_time = 3 #number of weeks until the ship can resupply
        while self.weeks_left > 0:
            #code here
            print(f"----------Week {self.current_week}----------")
            print(f"Weeks left: {self.weeks_left}")
            print(f"Ship level: {self.ship.level}")
            print(f"Supplies: {self.ship.supplies}/{self.ship.max_supplies}")
            print(f"Crew: {self.ship.crew}/{self.ship.max_crew}")
            print(f"Cargo: {self.ship.cargo}/{self.ship.max_cargo}")
            print(f"Ship health: {self.ship.health}/{self.ship.max_health}")
            print(f"Funds: {self.ship.funds}")
            print(f"Cannons: {self.ship.cannons}/{self.ship.max_cannons}")
            print(f"Weeks until resupply: {self.resupply_time}")
            

            RNGesus = random.randint(1,9)
            if RNGesus in self.events.keys():
                self.events[RNGesus]()
            #checks
            if self.ship.supplies <= 0:
                self.end_game()
            if self.ship.crew <= 0:
                self.end_game()
            if self.ship.health <= 0:
                self.end_game()
            if self.resupply_time == 0:
                self.resupply()
                self.resupply_time = 4
            #Update values
            self.current_week += 1
            self.weeks_left -= 1
            self.ship.supplies -= 10
            self.resupply_time -=1
            input("Press enter to continue")

    def becalmed(self):
        """
        simulates the ship being becalmed, delays voyage for a week
        """
        self.weeks_left += 1
        self.resupply_time += 1
        print(f"Your ship has been becalmed!")

    def storm(self):
        """
        simulates a thunderstorm, damaging the ship and killing crewmates and destroying cargo, with a 1% chance of sinking the ship entirely
        """
        crew_killed = random.randint(1,50)
        ship_damage = random.randint(1,50)
        ship_sinking = random.randint(1,100)
        cargo_lost = random.randint(1,100)
        if ship_sinking == 5:
            print("Your ship was destroyed in a thunderstorm!")
            self.end_game()
        else:
            print("Your ship was caught in a thunderstorm!")
            print(f"Crew lost: {crew_killed}")
            print(f"Ship damage: {ship_damage}")
            print(f"Cargo lost: {cargo_lost}")
            self.ship.changeCrew(-crew_killed)
            self.ship.changeCondition(-ship_damage)
            self.ship.changeCargo(-cargo_lost)

    
    
    def resupply(self):
        resupply_choice = util.user_select(["y","n"], message="Do you want to resupply? [y/n]: ")
        if resupply_choice == "n":
            return
        self.supply()
    def supply(self):
        supplying = True
        while supplying:
            print(f"Ship level: {self.ship.level}")
            print(f"Supplies: {self.ship.supplies}/{self.ship.max_supplies}")
            print(f"Crew: {self.ship.crew}/{self.ship.max_crew}")
            print(f"Funds: {self.ship.funds}")
            print(f"Ship health: {self.ship.health}/{self.ship.max_health}")
            print(f"Cannons: {self.ship.cannons}/{self.ship.max_cannons}")
            print("1: Buy supplies")
            print("2: Hire crew")
            print("3: Repair ship")
            print("4: Buy cannons")
            print("5: Upgrade Ship")
            print("x: Exit")
            supplying_choice = util.user_select(["1","2","3","4","5","x"], message="Select one: ")
            def __purchase(resourceFunc, cost_per_unit, max, resource):
                """
                function for purchasing supplies. resourceFunc is the type of supplies being purchased (the class method that changes it must be given) and cost_per_unit is the cost per one unit of that supply. Max is the maximum amount of that resource which the ship can support. Resource is the resource in question
                """
                amount = None
                while not isinstance(amount, int):
                    amount = input("How much would you like to purchase? ")
                    #tries to evaluate amount using literal_eval, and returns control to beginning of loop if it raises an exception while parsing
                    try:
                        amount = ast.literal_eval(amount)
                    except (ValueError, TypeError, SyntaxError, MemoryError, RecursionError):
                        continue
                cost = amount*cost_per_unit
                print(f"cost: {cost}")
                
                if resource+amount <= max:
                    if cost<self.ship.funds:
                        purchase_choice = util.user_select(["y","n"], message="Confirm purchase? [y/n]: ")
                        if purchase_choice == "y":
                            resourceFunc(amount)
                            self.ship.changeFunds(-cost)
                        
                    else:
                        print("You cannot afford this")
                else:
                    print("You need to upgrade your ship to do this")

                
            if supplying_choice == "1":
                #supplies
                __purchase(self.ship.changeSupply, 0.5, self.ship.max_supplies,self.ship.supplies)
                
            elif supplying_choice == "2":
                __purchase(self.ship.changeCrew, 3, self.ship.max_crew, self.ship.crew)

            elif supplying_choice == "3":
                cost = (self.ship.max_health-self.ship.health)*1.5
                print(f"cost: {cost}")
                if cost<self.ship.funds:
                    purchase_choice = util.user_select(["y","n"], message="Confirm repairs? [y/n]: ")
                    if purchase_choice == "y":
                        self.ship.health = self.ship.max_health
                        self.ship.changeFunds(-cost)
                    else: pass
                else:
                    print("You cannot afford this")
                    pass

            elif supplying_choice == "4":
                __purchase(self.ship.changeCannons, 10, self.ship.max_cannons, self.ship.cannons)
            
            elif supplying_choice == "5":
                cost = 5000 + self.ship.level * 2000
                print(f"cost: {cost}")
                if cost<self.ship.funds:
                    purchase_choice = util.user_select(["y","n"], message="Upgrade Ship? [y/n]: ")
                    if purchase_choice == "y":
                        self.ship.level += 1
                        self.ship.updateMax()
                        self.ship.changeFunds(-cost)
                    else: pass
                else:
                    print("You cannot afford this")
                    pass
            elif supplying_choice == "x":
                supplying = False
    def end_game(self):
        self.game_state = 2
        self.weeks_left = 0

    def warship_attack(self):
        #(Ship name, prize money, success modifier)
        warship = random.choice([("Man-of-War", 30000, 0.02),("Light Ship", 5000, 0.1)])
        ship_win_chance = 1-(1/((warship[2]*self.ship.cannons)+1))
        ship_win_percentage = round(ship_win_chance*100, ndigits=2)
        ship_win_string = str(ship_win_percentage)
        print(f"You are being attacked by a {warship[0]}")
        print(f"Your cannons: {self.ship.cannons}")
        print(f"Chance of success if you fight: {ship_win_string}%")
        print("Chance of success if you flee: 90.00%")
        print("1 to fight")
        print("2 to flee")
        fight_or_flee = util.user_select(["1","2"],message="Select one: ")
        if fight_or_flee == "1":
            victory = util.prob_decision(ship_win_chance)
            if victory:
                crew_lost = random.randint(0,40)
                ship_damage = random.randint(0,30)
                print("You successfully captured the warship as your prize!")
                print(f"Crew lost: {crew_lost}")
                print(f"Ship damage: {ship_damage}")
                print(f"Loot: {warship[1]}")
                self.ship.changeCrew(-crew_lost)
                self.ship.changeCondition(-ship_damage)
                self.ship.changeFunds(warship[1])
                return
            else:
                print("You have lost the battle, and the warship has killed you and your entire crew!")
                self.end_game()
                return
                
        elif fight_or_flee == "2":
            victory = util.prob_decision(0.9)
            if victory:
                print("You successfully outran the warship!")
                return
            else:
                print("The warship caught up with you, and has seriously damaged your ship")
                crew_lost = random.randint(0,90)
                ship_damage = random.randint(0,80)
                print(f"Crew lost: {crew_lost}")
                print(f"Ship damage: {ship_damage}")
                self.ship.changeCrew(-crew_lost)
                self.ship.changeCondition(-ship_damage)
                return
    def merchant_ship(self):
        loot = random.choice([500, 500, 500, 500, 600, 600, 600, 700, 700, 1000])#500: 40%, 600: 30%, 700: 20%, 1000: 10%
        ship_win_chance = 1-(1/((0.3*self.ship.cannons)+1))
        ship_win_percentage = round(ship_win_chance*100, ndigits=2)
        ship_win_string = str(ship_win_percentage)
        print("You see a merchant ship!")
        print(f"Chance of winning if you attack: {ship_win_string}%")
        attack_or_not = util.user_select(["y","n"],message="Do you want to attack? [y/n]: ")
        if attack_or_not == "y":
            victory = util.prob_decision(ship_win_chance)
            if victory:
                crew_lost = random.randint(0,20)
                ship_damage = random.randint(0,10)
                print("You successfully attacked the merchant ship and took all of its cargo!")
                print(f"Crew lost: {crew_lost}")
                print(f"Ship damage: {ship_damage}")
                print(f"Loot: {loot}")
                self.ship.changeCrew(-crew_lost)
                self.ship.changeCondition(-ship_damage)
                self.ship.changeCargo(loot)
            else:
                print("The merchant ship successfully defended against you")
                crew_lost = random.randint(0,40)
                ship_damage = random.randint(0,40)
                print(f"Crew lost: {crew_lost}")
                print(f"Ship damage: {ship_damage}")
                self.ship.changeCrew(-crew_lost)
                self.ship.changeCondition(-ship_damage)
                return
        else:
            return
        

        
instance()

