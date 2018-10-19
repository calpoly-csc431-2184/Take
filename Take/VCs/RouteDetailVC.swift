import Mapbox
import TwicketSegmentedControl
import UIKit

class RouteDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TwicketSegmentedControlDelegate, MGLMapViewDelegate {

    var route: Route!
    var imageKeys: [String] = []
    var images: [String: UIImage] = [:]
    var diagramKeys: [String] = []
    var diagrams: [String: [UIImage]] = [:]

    var myImagesCV: UICollectionView!
    var myDiagramsCV: UICollectionView!
    var imagesCVConst: NSLayoutConstraint!
    var bgImageView: UIImageView!
    var infoLabel: UILabel!

    let cvHeight: CGFloat = 75

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()

        DispatchQueue.global(qos: .background).async {
            self.route.fsLoadAR { diagrams in
                self.diagrams = diagrams
                for diagram in self.diagrams {
                    self.diagramKeys.append(diagram.key)
                }
                DispatchQueue.main.async {
                    self.myDiagramsCV.reloadData()
                }
            }

            self.route.fsLoadImages { images in
                self.images = images
                for image in self.images {
                    self.imageKeys.append(image.key)
                }
                DispatchQueue.main.async {
                    if let firstImage = images.first {
                        self.bgImageView.image = firstImage.value
                    }
                    self.myImagesCV.reloadData()
                }
            }
        }

    }

    @objc
    func goFavorite(sender: UIButton!) {
        print("add to favorites")
    }

    @objc
    func goToDo(sender: UIButton!) {
        print("add to do")
    }

    @objc
    func goEdit(sender: UIButton!) {
        print("going to edit")
    }

    // MARK: - Twicket Seg Control
    func didSelect(_ segmentIndex: Int) {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.infoLabel.alpha = 0.0
        }, completion: { _ in
            self.infoLabel.text = segmentIndex == 0 ? self.route.info : self.route.protection
            UIView.animate(withDuration: 0.3,
                           animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.infoLabel.alpha = 1.0
                }
            })
        })
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == myImagesCV ? imageKeys.count : diagramKeys.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == myImagesCV, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteDetailCVCell", for: indexPath) as? RouteDetailCVCell {
            if let cellImage = self.images[self.imageKeys[indexPath.row]] {
                cell.initImage(image: cellImage)
            }
            return cell
        } else if collectionView == myDiagramsCV, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteDetailDiagramCVCell", for: indexPath) as? RouteDetailDiagramCVCell {
            if let theImage = self.diagrams[diagramKeys[indexPath.row]] {
                cell.initImage(bgImage: theImage[0], diagramImage: theImage[1])
            }
            return cell
        }
        return UICollectionViewCell()
    }

    // MARK: - mapbox
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func initViews() {
        self.view.backgroundColor = UIColor(named: "BluePrimary")
        self.title = route.name
        let editButton = UIBarButtonItem(image: UIImage(named: "edit.png")?.resized(withPercentage: 0.5), style: .plain, target: self, action: #selector(goEdit))
        navigationItem.rightBarButtonItem = editButton

        // bg image
        self.bgImageView = UIImageView(frame: self.view.frame)
        self.bgImageView.contentMode = .scaleAspectFill
        self.bgImageView.clipsToBounds = true
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.view.frame
        self.bgImageView.addSubview(effectView)
        let gradientView = UIView(frame: self.view.frame)
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor(named: "BluePrimaryDark")?.cgColor as Any, UIColor.clear.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)

        // image collectionview
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: cvHeight, height: cvHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        self.myImagesCV = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.myImagesCV.register(RouteDetailCVCell.self, forCellWithReuseIdentifier: "RouteDetailCVCell")
        self.myImagesCV.delegate = self
        self.myImagesCV.dataSource = self
        self.myImagesCV.backgroundColor = .clear
        self.myImagesCV.showsHorizontalScrollIndicator = false

        // diagram collectionview
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout2.itemSize = CGSize(width: cvHeight, height: cvHeight)
        layout2.minimumInteritemSpacing = 0
        layout2.minimumLineSpacing = 5
        layout2.scrollDirection = .horizontal
        self.myDiagramsCV = UICollectionView(frame: self.view.frame, collectionViewLayout: layout2)
        self.myDiagramsCV.register(RouteDetailDiagramCVCell.self, forCellWithReuseIdentifier: "RouteDetailDiagramCVCell")
        self.myDiagramsCV.delegate = self
        self.myDiagramsCV.dataSource = self
        self.myDiagramsCV.backgroundColor = .clear
        self.myDiagramsCV.showsHorizontalScrollIndicator = false

        // segment control
        let segControl = TwicketSegmentedControl()
        segControl.setSegmentItems(["Description", "Protection"])
        segControl.isSliderShadowHidden = true
        segControl.sliderBackgroundColor = UIColor(named: "BlueDark") ?? .lightGray
        segControl.delegate = self

        // info label
        infoLabel = UILabel()
        infoLabel.text = route.info
        infoLabel.numberOfLines = 0
        infoLabel.textColor = .white
        infoLabel.font = UIFont(name: "Avenir-Oblique", size: 15)

        // mapbox map
        let url = URL(string: "mapbox://styles/mapbox/dark-v9")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.delegate = self
        mapView.setCenter(CLLocationCoordinate2D(latitude: route.latitude ?? 0, longitude: route.longitude ?? 0), zoomLevel: 15, animated: false)
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        let routeMarker = MGLPointAnnotation()
        routeMarker.coordinate = CLLocationCoordinate2D(latitude: route.latitude ?? 0, longitude: route.longitude ?? 0)
        routeMarker.title = route.name
        routeMarker.subtitle = "\(route.rating ?? "") \(route.typesString)"
        mapView.addAnnotation(routeMarker)

        // add to subview
        view.addSubview(bgImageView)
        view.addSubview(gradientView)
        view.addSubview(myImagesCV)
        view.addSubview(myDiagramsCV)
        view.addSubview(segControl)
        view.addSubview(infoLabel)
        view.addSubview(mapView)

        // constraints
        myImagesCV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: myImagesCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: myImagesCV, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cvHeight).isActive = true

        myDiagramsCV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: myDiagramsCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myDiagramsCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: myDiagramsCV, attribute: .top, relatedBy: .equal, toItem: myImagesCV, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: myDiagramsCV, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cvHeight).isActive = true

        segControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: segControl, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: segControl, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -40).isActive = true
        NSLayoutConstraint(item: segControl, attribute: .top, relatedBy: .equal, toItem: myDiagramsCV, attribute: .bottom, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: segControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 25).isActive = true
        NSLayoutConstraint(item: infoLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -25).isActive = true
        NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: segControl, attribute: .bottom, multiplier: 1, constant: 10).isActive = true

        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -5).isActive = true
        NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: infoLabel, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: mapView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true

    }

}
