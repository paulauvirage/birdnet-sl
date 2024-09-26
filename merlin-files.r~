library(reticulate)
library(birdnetR)
library(tidyverse)

# install_birdnet() # only run once - it populates the venv with python packages etc 

# load and name the model engine

model <- birdnet_model_tflite()

# get a prediction for SL birds (I chose central coordinate, not sure what radius is used)

meta_model <- birdnet_model_meta() 

sl_list <- predict_species_at_location_and_time(meta_model, latitude = 8.6, longitude = -12.0)

head(sl_list)

# get the species as a list

sl_birds <- as.list(sl_list$label)

head(sl_birds)

glimpse(sl_birds)

# iterate over files

paths <- list.files("~/Music/birdnet_input", full.names = TRUE)

arg <- list(audio_file = paths) 

p <- pmap(arg, predict_species_from_audio_file, model = model, filter = sl_birds)
p
q <- bind_rows(p, .id = "group id")

q$end <- round(q$end, 1)
q$confidence <- round(q$confidence, 1)

knitr::kable(q)


predictions <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav")

predictions <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav", chunk_overlap_s = 2, filter_species = sl_birds)

# pull out and save top predictions, rounded, as a df and view with

top_predictions <- as.data.frame(get_top_prediction(predictions))

top_predictions$confidence <- round(top_predictions$confidence, 1)

knitr::kable (top_predictions)



# repeat the model, filtered on SL birds

predictions_b <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav", filter_species = sl_birds)

# note Eurasian Tree Sparrow disappears from the predictions 

top_predictions_b <- as.data.frame(get_top_prediction(predictions_b))

top_predictions_b$confidence <- round(top_predictions_b$confidence, 1)

knitr::kable (top_predictions_b)

# save and reload RDS

saveRDS(sl_birds, file =  "sl_birds.RData")

sl_birds_b <- readRDS("sl_birds.RData")

glimpse(sl_birds_b)
