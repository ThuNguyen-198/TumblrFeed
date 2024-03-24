//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke
private var postList : [Post] = []
class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as! PostCell
        
        let post = postList[indexPath.row]
        
        // Check if the post has photos
        if !post.photos.isEmpty {
            // Load the first photo into the cell

               if let imageUrl = URL(string: post.photos[0].originalSize.url) {
                // Use the Nuke library's load image function to asynchronously fetch and load the image from the image URL.
                Nuke.loadImage(with: imageUrl, into: cell.posterImage)
            }
            cell.postDescription.text = post.summary
            cell.postDescription.numberOfLines = 0
        }
        
        return cell
    }



    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        fetchPosts()
    }
    
    
    
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("❌ Data is NIL")
                return
            }
            
            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    
                    let posts = blog.response.posts
                    postList = posts
                    self?.tableView.reloadData()
                    
//                    print("✅ We got \(posts.count) posts!")
//                    for post in posts {
//                        print("🍏 Summary: \(post.summary)")
//                    }
                }
                
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    
}
