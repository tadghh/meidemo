
# # Make sure no previous, is running
# system("pkill -f meilisearch")

# # Wait
# system("sleep 1")

# # Start server
# system("./meilisearch --master-key=34528d9b5c9638642b48e810da7c0499 --no-analytics &")

# # Wait for boot to complete
# system("sleep 1")

# Dump current indexs
# Post.clear_index!
# Community.clear_index!
# Post.destroy_all
# Community.destroy_all
catCommunity = Community.create!(name: 'CatCommunity', description: 'cats yo.')
dogCommunity = Community.create!(name: 'DogCommunity', description: 'dogs yo.')

# Cat posts
Post.create!(title: 'Types of cats', content: 'What are the top cats in 2024?', community: catCommunity)
Post.create!(title: 'Is my cat excessibley long?', content: 'How long should my cat be?', community: catCommunity)
Post.create!(title: 'Heckin chonkers, normalization of overfeeding', content: 'Why is your cat obese?', community: catCommunity)
Post.create!(title: 'Woah woah 100 reddit golds!', content: 'Mods hes doing it sideways!', community: catCommunity)
# Dog posts
Post.create!(title: 'Dogs out?', content: 'is it a dogs out sort of summer?', community: dogCommunity)

Post.reindex!
Community.reindex!

# system("pkill -f meilisearch")

puts "Seed data created successfully!"
