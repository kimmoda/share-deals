# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SEED_CATEGORIES = [
  'Bags & Luggage',
  'Books & Magazines',
  'Clothing, Shoes & Accessories',
  'Computers',
  'Entertainment',
  'Grocery',
  'Health & Beauty',
  'Home & Home Improvement',
  'Movies',
  'Office & School Supplies',
  'Other',
  'Pets',
  'Phones',
  'Restaurants',
  'Services',
  'Shoes',
  'Sporting Goods',
  'Tech & Electronics',
  'Travel',
  'Video Games'
]

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

def random_user
  username = Faker::Internet.user_name
  {
    username: username,
    email: "#{username.downcase}.example.com",
    password: Faker::Internet.password(8)
  }
end

def random_deal
  product_name = Faker::Commerce.product_name

  {
    category: SEED_CATEGORIES.sample,
    title: product_name,
    price: Faker::Commerce.price,
    vendor: Faker::Company.name,
    description: Faker::Lorem.paragraphs(rand(2..4)).join('\n'),
    deal_url: 'https://www.amazon.com/',
    cloud_url: Faker::Placeholdit.image('300x300', 'png'),
    author_id: (1..100).to_a.sample,
  }
end

def random_thumb
  {
    deal_id: (1..100).to_a.sample,
    user_id: (1..40).to_a.sample,
    value: [-1, 1, 1, 1].sample
  }
end

users = [
  { username: 'Guest', email: 'guestaccount@gmail.com', password: 'password' },
  { username: 'Isai', email: 'isaialvarado@gmail.com', password: 'password' }
]

40.times { users.push(random_user) }
User.create(users)
deals = []
100.times { deals.push(random_deal) }
Deal.create(deals)

thumbs = []
id_pairs = []
(25 * 70).times do
  thumb = random_thumb
  id_pair = [thumb[:user_id], thumb[:deal_id]]
  unless id_pairs.include?(id_pair)
    id_pairs << id_pair
    thumbs << thumb
  end
end

Thumb.create(thumbs)

# deals = [
#   {
#     category: "Health & Beauty",
#     title: Faker::Commerce.product_name,
#     price: Faker::Commerce.price,
#     vendor: Faker::Company.name,
#     description: "Amazon Dot",
#     deal_url: "https://www.amazon.com/All-New-Amazon-Echo-Dot-Add-Alexa-To-Any-Room/dp/B01DFKC2SO",
#     author_id: 1,
#     cloud_url: "https://res.cloudinary.com/ssb64/image/upload/v1484521598/umn0pr2erlwyik552laz.jpg",
#     image_url: "https://images-na.ssl-images-amazon.com/images/I/51puyU9501L._SY300_.jpg"
#   },
#   {
#     category: "Video Games",
#     title: "Super Mario Odyssey",
#     price: 59.99,
#     vendor: "Amazon",
#     description: "Nintendo Switch Game",
#     deal_url: "https://www.amazon.com/Super-Mario-Odyssey-Switch/dp/B01MY7GHKJ/ref=sr_1_cc_3?s=aps&ie=UTF8&qid=1484522996&sr=1-3-catcorr&keywords=nintendo+switch",
#     author_id: 1,
#     cloud_url: "https://res.cloudinary.com/ssb64/image/upload/v1484525873/su9y03xs5urerm80t3q2.jpg",
#     image_url: "https://images-na.ssl-images-amazon.com/images/I/41dIKJQ53cL._AC_SX215_.jpg"
#   }
# ]
