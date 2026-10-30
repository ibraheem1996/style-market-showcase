sealed class AdminCollectionItemsEffect {
  const AdminCollectionItemsEffect();
}

class AdminCollectionItemsMessageEffect extends AdminCollectionItemsEffect {
  const AdminCollectionItemsMessageEffect(this.message);

  final String message;
}
