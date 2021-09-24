//
//  ListTableViewController.swift
//  Reciplease
//
//  Created by Romain Buewaert on 13/09/2021.
//

import UIKit

final class ListTableViewController: UITableViewController {
    // MARK: - Properties
    var ingredients = ""
    var recipeList = RecipeList(list: [])
    var findMoreRecipe = false

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200

        RecipeManage.shared.getFirstRecipes(ingredients: ingredients) { result in
            switch result {
            case .success(let recipeList):
                self.recipeList = recipeList
                self.tableView.reloadData()
            case .failure(let error):
                self.alertErrorMessage(message: error.rawValue)
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as? RecipeTableViewCell else {
            return UITableViewCell()
        }

        let recipe = recipeList.list[indexPath.row]

        guard let imageUrl = recipe.imageUrl else {
            cell.configureWithDefaultImage(title: recipe.title, ingredients: recipe.ingredientName, cuisineType: recipe.cuisineType, time: recipe.totalTime)
            return cell
        }

        guard imageUrl.hasSuffix(".jpg") || imageUrl.hasSuffix(".png") else {
            cell.configureWithDefaultImage(title: recipe.title, ingredients: recipe.ingredientName, cuisineType: recipe.cuisineType, time: recipe.totalTime)
            return cell
        }

        RecipeManage.shared.getImage(url: recipe.imageUrl!) { result in
            switch result {
            case .success(let image):
                cell.configure(imageData: image, title: recipe.title, ingredients: recipe.ingredientName, cuisineType: recipe.cuisineType, time: recipe.totalTime)
            case .failure(_):
                cell.configureWithDefaultImage(title: recipe.title, ingredients: recipe.ingredientName, cuisineType: recipe.cuisineType, time: recipe.totalTime)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Recipe") as? RecipeViewController {
            vc.selectedRecipe = recipeList.list[indexPath.row]

            guard let currentCell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell else { return }
            guard let currentImage = currentCell.recipeImageView.image else { return }
            vc.selectedRecipeImage = currentImage

            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let positionY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if positionY > contentHeight - scrollView.frame.height * 2, RecipeManage.urlNextPage != "" {
            if !findMoreRecipe {
                loadMoreRecipe()
            }
        }
    }

    // MARK: - Private methods
    private func createFooterActivityIndicator() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = footerView.center
        footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        return footerView
    }

    private func loadMoreRecipe() {
        findMoreRecipe = true
        self.tableView.tableFooterView = createFooterActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            RecipeManage.shared.getOtherRecipes(url: RecipeManage.urlNextPage) { result in
                self.tableView.tableFooterView = nil
                switch result {
                case .success(let nextRecipeList):
                    for recipe in nextRecipeList.list {
                        self.recipeList.list.append(recipe)
                    }
                    self.findMoreRecipe = false
                    self.tableView.reloadData()
                    print(self.recipeList.list.count)
                case .failure(let error):
                    self.alertErrorMessage(message: error.rawValue)
                }
            }
        }
    }

    // MARK: - UIAlertController
    private func alertErrorMessage(message: String) {
        let alertVC = UIAlertController(title: "Error!", message: message,
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}


//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
