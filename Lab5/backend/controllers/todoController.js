const Todo = require("../models/Todo");

const getTodos = async (req, res) => {
  try {
    const todos = await Todo.find({ user: req.user.id }).sort({ createdAt: -1 });
    return res.json({ message: "Lấy danh sách công việc thành công", todos });
  } catch (error) {
    return res.status(500).json({ message: "Không thể lấy danh sách công việc", error: error.message });
  }
};

const createTodo = async (req, res) => {
  try {
    const { title, description } = req.body;

    if (!title || !title.trim()) {
      return res.status(400).json({ message: "Vui lòng nhập tiêu đề công việc" });
    }

    const todo = await Todo.create({
      user: req.user.id,
      title: title.trim(),
      description: description ? description.trim() : "",
    });

    return res.status(201).json({ message: "Thêm công việc thành công", todo });
  } catch (error) {
    return res.status(500).json({ message: "Không thể thêm công việc", error: error.message });
  }
};

const updateTodo = async (req, res) => {
  try {
    const { title, description, isDone } = req.body;

    if (title !== undefined && !title.trim()) {
      return res.status(400).json({ message: "Tiêu đề công việc không được để trống" });
    }

    const updates = {};
    if (title !== undefined) updates.title = title.trim();
    if (description !== undefined) updates.description = description.trim();
    if (isDone !== undefined) updates.isDone = Boolean(isDone);

    const todo = await Todo.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      updates,
      { new: true, runValidators: true }
    );

    if (!todo) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    return res.json({ message: "Cập nhật công việc thành công", todo });
  } catch (error) {
    return res.status(500).json({ message: "Không thể cập nhật công việc", error: error.message });
  }
};

const toggleTodo = async (req, res) => {
  try {
    const todo = await Todo.findOne({ _id: req.params.id, user: req.user.id });

    if (!todo) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    todo.isDone = !todo.isDone;
    await todo.save();

    return res.json({ message: "Đổi trạng thái công việc thành công", todo });
  } catch (error) {
    return res.status(500).json({ message: "Không thể đổi trạng thái công việc", error: error.message });
  }
};

const deleteTodo = async (req, res) => {
  try {
    const todo = await Todo.findOneAndDelete({ _id: req.params.id, user: req.user.id });

    if (!todo) {
      return res.status(404).json({ message: "Không tìm thấy công việc" });
    }

    return res.json({ message: "Xóa công việc thành công" });
  } catch (error) {
    return res.status(500).json({ message: "Không thể xóa công việc", error: error.message });
  }
};

module.exports = {
  getTodos,
  createTodo,
  updateTodo,
  toggleTodo,
  deleteTodo,
};
