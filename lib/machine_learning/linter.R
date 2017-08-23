library(lintr)

lint("machine_learning_lib.R", with_defaults(line_length_linter = line_length_linter(100)))
lint("find_model.R", with_defaults(line_length_linter = line_length_linter(100)))
lint("use_model.R", with_defaults(line_length_linter = line_length_linter(100)))
