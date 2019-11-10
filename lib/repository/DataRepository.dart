

abstract class DataRepository<T> {
  Future<int> create(T item);
  Future<bool> update(int id, T data);
  Future<List<T>> getAll();
  Future<T> get(int id);
  Future<bool> delete(int id);
  Future<void> closeDB();
}