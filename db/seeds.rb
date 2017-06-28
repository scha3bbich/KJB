# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ScoutConsumption.delete_all
ChildConsumption.delete_all
Booking.delete_all

Account.delete_all
MainAccount.delete_all
ScoutAccount.delete_all
ChildAccount.delete_all

MainAccount.create([{name: 'Lagerkasse Bar'}, {name: 'Gruppenleiterkasse Girokonto'}, {name: 'Gruppenleiterkasse'}, {name: 'Kinderkasse'}])

User.delete_all
User.create([{name: 'Annalena'}, {name: 'Tobias'}, {name: 'Johannes'}, {name: 'Gast'}])

Tent.delete_all
Tent.create([{number: '1', name: 'Zelt 1'}, {number: '2', name: 'Zelt 2'}, {number: '3', name: 'Zelt 3'}, {number: '4', name: 'Zelt 4'}, {number: '5', name: 'Zelt 5'}, 
  {number: '6', name: 'Zelt 6'}, {number: '7', name: 'Zelt 7'}, {number: '8', name: 'Zelt 8'}, {number: '9', name: 'Zelt 9'}, {number: '10', name: 'Zelt 10'}, 
  {number: '11', name: 'Zelt 11'}, {number: '12', name: 'Zelt 12'}, {number: '13', name: 'Zelt 13'}, {number: '14', name: 'Zelt 14'}, {number: '15', name: 'Zelt 15'}, 
  {number: '16', name: 'Zelt 16'}, {number: '17', name: 'Zelt 17'}, {number: '18', name: 'Zelt 18'}, ])

Scout.delete_all
Child.delete_all

Setting.delete_all
Setting.create([ 
    {key: :start_date, type: :date, value: "2017-07-13"},
    {key: :end_date, type: :date, value: "2017-07-30"}
])

Good.delete_all
Good.create([{type: :beer, price: "0.7", date: "2017-01-01"},
            {type: :soft_drink, price: "0.5", date: "2017-01-01"},
            {type: :sausage, price: "1.0", date: "2017-01-01"},
            {type: :pork, price: "1.2", date: "2017-01-01"},
            {type: :turkey, price: "2.0", date: "2017-01-01"},
            {type: :corn, price: "1.0", date: "2017-01-01"}
 ])