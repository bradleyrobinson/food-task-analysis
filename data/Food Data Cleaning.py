# Open up the file
import pandas as pd
import glob, os



# Let's combine all of this script right here
def get_ratings(food_df):
    all_ratings = food_df[pd.isnull(food_df["Decision"]) == True]

    # Separate the two rating tasks
    middle = int(all_ratings.shape[0] / 2)
    pre_rating = all_ratings.iloc[0:middle]
    post_rating = all_ratings.iloc[middle:all_ratings.shape[0]]

    # First redo the columns for pre_rating
    new_columns = [x for x in pre_rating.columns]
    new_columns[2] = "Pre-rating"
    pre_rating.columns = new_columns

    # Then for post-rating
    new_columns[2] = "Post-rating"
    post_rating.columns = new_columns

    # Get rid of the columns that really don't matter
    cols_drop = ['Participant', 'Trial Food C', 'Trial Food D', 'Decision', 'Opponent Decision', 'RT']
    post_rating = post_rating.drop(cols_drop, axis=1)
    pre_rating = pre_rating.drop(cols_drop, axis=1)
    # Combine the two datasets
    ratings = pre_rating
    ratings['post_rating'] = post_rating['Post-rating'].values
    # Get the change from pre and post rating
    ratings['rating_difference'] = ratings['post_rating'].subtract(ratings['Pre-rating'])
    # Let's find the sum of all zeros
    r_zero = ratings[ratings['rating_difference'] == 0].shape[0]
    r_change = ratings[ratings['rating_difference'] != 0].shape[0]
    # Return ratings
    return ratings, r_zero, r_change


def get_decisions(food):
    return food[pd.isnull(food["Food Rated"]) == True]


def decision_foods(food):
    # This is the food the participa
    food = get_decisions(food)
    cols_drop = ['Food Rated', 'Food Rating', 'Opponent Decision']
    food = food.drop(cols_drop, axis=1)
    food['picked_food'] = food['Trial Food C']

    for i in range(food.shape[0]):
        if food['Decision'].iloc[i] == 'D':
            food['picked_food'].iloc[i] = food['Trial Food D'].iloc[i]
    food = food.drop(['RT', 'Participant', 'Unnamed: 8', 'Trial Food C', 'Trial Food D'], axis=1)
    food.reset_index(inplace=True)
    return food


def changed_food(ratings, decisions):
    # Make a new dataframe out of decisions
    new_decision = decisions
    new_decision['changed'] = False
    # Make a list of all the food ratings that have changed
    changed_ratings = ratings[ratings['rating_difference'] != 0]
    for food in changed_ratings["Food Rated"]:
        # Check to make sure that the food is there first
        if decisions[decisions['picked_food']==food].shape[0] > 0:
            i = list(decisions['picked_food']).index(food)
            new_decision['changed'].iloc[i] = True
    new_decision['pick_changed'] = 0
    # Now we will find out how much the rating change IF we changed the rating
    for i in range(new_decision.shape[0]):
        food_loc = list(ratings['Food Rated']).index(new_decision['picked_food'].iloc[i])
        new_decision['pick_changed'].iloc[i] = ratings['rating_difference'].iloc[food_loc]
    return new_decision


file_list = [csv for csv in glob.glob("*.csv")]
print(file_list)

for file in file_list:
    if 'TP' not in file:
        new_name = file[0:11] + 'T' + file[11:]
        if new_name not in file_list:
            os.rename(file, new_name)

# We might as well do this again:
file_list = [csv for csv in glob.glob("*.csv")]
# Now we need to export the data so that it can be used
# Since the last stuff was to visualize the data, we're going to do the stuff again (it is fast...)
for file in file_list:
    p_name = file[13:15]
    foods = pd.read_csv(file)
    decisions = decision_foods(foods)
    ratings, a, b = get_ratings(foods)
    new_d = changed_food(ratings, decisions)
    new_d = new_d.drop(['picked_food', 'pick_changed'],axis=1)
    new_d.to_csv(path_or_buf=os.path.join("Post", p_name + 'decisions.csv'))
    print("!")