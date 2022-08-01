import UIKit

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var selectedCell: UICollectionViewCell?
    private var coordinator: TransitionCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        // Set the cells sizes and layout direction
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 335, height: 410)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        self.collectionView.collectionViewLayout = layout

        self.collectionView.register(cellType: CardCell.self)
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: CardCell.self)
        return cell
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCell = self.collectionView.cellForItem(at: indexPath)

        let vc = DetailViewController.instantiate()
        coordinator = TransitionCoordinator(mainViewController: self, detailViewController: vc)
        vc.myTransitionCoordinator = coordinator
        coordinator.presentTransition()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CollectionViewController: Animatable {
    var containerView: UIView? {
        return self.collectionView
    }

    var childView: UIView? {
        return self.selectedCell
    }
}
