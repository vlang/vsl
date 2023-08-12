module ml

import rand
import vsl.errors

pub struct RandomForest {
	name string
mut:
	n_trees           int
	trees             []DecisionTree
	data              &Data[f64]
	stat              &Stat[f64]
	min_samples_split int
	max_depth         int
	n_feats           int
}

pub fn init_forest(mut data Data[f64], n_trees int, trees []DecisionTree, min_samples_split int, max_depth int, n_feats int) RandomForest {
	forest_data := new_data[f64](data.nb_samples, n_feats, true, false) or {
		panic('could not create new data to initialise forest')
	}
	// stat
	mut stat := stat_from_data(mut data, 'stat_')
	stat.update()
	return RandomForest{'${n_trees}-${min_samples_split}-${max_depth}-${n_feats}', n_trees, trees, forest_data, stat, min_samples_split, max_depth, n_feats}
}

fn (mut rf RandomForest) fit(x [][]f64, y []f64) ! {
	n_samples := x.len
	mut sample_list := []int{}
	for s in 0 .. n_samples {
		sample_list << s
	}
	for _ in 0 .. rf.n_trees {
		mut tree_data := data_from_raw_xy_sep(x, y) or {
			return errors.error('could not create data for tree', .efailed)
		}
		mut tree := init_tree(mut tree_data, rf.min_samples_split, rf.max_depth, rf.n_feats,
			'${rf.min_samples_split}-${rf.max_depth}-${rf.n_feats}')
		// sample x and y
		mut idxs := rand.choose(sample_list, n_samples) or {
			return errors.error('could not choose random sample', .efailed)
		}
		rf.fit(idxs.map(x[it]), idxs.map(y[it]))!
		rf.trees << tree
	}
}

fn (mut rf RandomForest) predict(x [][]f64) []f64 {
	mut tpreds := [][]f64{}
	for t in 0 .. rf.trees.len {
		tpreds << rf.trees[t].predict(x)
	}
	mut ypreds := []f64{}
	ypreds << tpreds.map(most_common(it))
	return []f64{}
}
