import Blueprints
import FirebaseAuth
import FirebaseFirestore
//import Lightbox
import UIKit

class RoutePhotosVC: UIViewController {

    // MARK: - Injections
    var routeViewModel: RouteViewModel!

    // MARK: - Outlets
    var myImagesCV: UICollectionView!

    struct ARImageComment {
        var image: ARImageUrls
        var comment: String?
    }

    // MARK: - Variables
    var images: [ARImageComment] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initViews()

        DispatchQueue.global(qos: .background).async {

            FirestoreService.shared.fs.listen(collection: "arDiagrams", by: "routeId", with: self.routeViewModel.id, of: ARDiagram.self) { arDiagram in
                let image = ARImageUrls(dgImage: arDiagram.dgImageUrl, bgImage: arDiagram.bgImageUrl)
                let arImageContent = ARImageComment(image: image, comment: arDiagram.message)
                DispatchQueue.main.async {
                    self.images.insert(arImageContent, at: 0)
                    self.myImagesCV.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
            }

            FirestoreService.shared.fs.listen(collection: "comments", by: "routeId", with: self.routeViewModel.id, of: Comment.self) { comment in
                guard let imgUrl = CommentViewModel(comment: comment).imageUrl else { return }
                let image = ARImageUrls(bgImage: imgUrl)
                let arImageContent = ARImageComment(image: image, comment: comment.message)
                DispatchQueue.main.async {
                    self.images.insert(arImageContent, at: 0)
                    self.myImagesCV.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
            }
        }

    }

    func initViews() {
        self.view.backgroundColor = UIColor(named: "BluePrimaryDark")
        self.title = routeViewModel.name

        let waterfallLayout = VerticalBlueprintLayout(
            itemsPerRow: 2,
            itemSize: CGSize(width: view.frame.width / 3, height: view.frame.width / 1.5),
            minimumInteritemSpacing: 10,
            minimumLineSpacing: 10,
            sectionInset: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        myImagesCV = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout)
        myImagesCV.register(RoutePhotosCVC.self, forCellWithReuseIdentifier: "RoutePhotoCVCell")
        myImagesCV.delegate = self
        myImagesCV.dataSource = self
        myImagesCV.backgroundColor = .clear
        myImagesCV.showsHorizontalScrollIndicator = false

        view.addSubview(myImagesCV)

        myImagesCV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: myImagesCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true

    }

}
