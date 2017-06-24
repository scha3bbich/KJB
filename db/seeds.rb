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