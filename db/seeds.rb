
if Rails.env.development?
  # Make sure no previous instance is running
  system("pkill -f meilisearch")

  # Wait
  sleep 1

  # Start Meilisearch server
  system("./meilisearch --no-analytics &")

  # Wait for boot to complete
  sleep 1

  # Dump current indexes
  Post.clear_index!
  Community.clear_index!
  Post.destroy_all
  Community.destroy_all
end


catCommunity = Community.create!(name: 'CatCommunity', description: 'cats yo.')
dogCommunity = Community.create!(name: 'DogCommunity', description: 'dogs yo.')

# Cat posts
Post.create!(title: 'Types of cats', content: 'What are the top cats in 2024?', community: catCommunity)
Post.create!(title: 'Is my cat excessibley long?', content: 'How long should my cat be?', community: catCommunity)
Post.create!(title: 'Heckin chonkers, normalization of overfeeding', content: 'Why is your cat obese?', community: catCommunity)
Post.create!(title: 'Woah woah 100 reddit golds!', content: 'Mods hes doing it sideways!', community: catCommunity)
# Dog posts
Post.create!(title: 'Dogs out?', content: 'is it a dogs out sort of summer?', community: dogCommunity)


if Rails.env.development?
  system("pkill -f meilisearch")
end

puts "Seed data created successfully!"
